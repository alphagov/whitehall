require 'gds_api/content_store'

# Check to see how complete the (live) content-store's copies of data are.
#
#   pasc = DataHygiene::PublishingApiSyncCheck.new(StatisticsAnnouncement.limit(100))
#   pasc.add_expectation { |json, model| json.fetch("format") == "statistics_announcement" }
#   pasc.perform
#
# The disadvantages of running against content-store are that you can't inspect
# things like rendering_app.
#
# On the other hand, if you don't trust publishing-api's ability to push to
# content-store...
#
# If we used publishing-api, we could use its index endpoint to do this all in
# a single request. The problem is that that endpoint currently doesn't do
# pagination, so it won't (reliably) handle lots of items...
module DataHygiene
  class PublishingApiSyncCheck
    class Success
      attr_reader :base_path

      def initialize(base_path:)
        @base_path = base_path
      end
    end

    class Failure
      attr_reader :base_path, :failed_expectations

      def initialize(base_path:, failed_expectations:, content_store:)
        @base_path = base_path
        @failed_expectations = failed_expectations
        @content_store = content_store
      end

      def to_s
        "Failed path: #{@base_path} in #{@content_store.titleize}, failed expectations: #{@failed_expectations.join(', ')}"
      end

      def ==(other)
        self.base_path == other.base_path && self.failed_expectations == other.failed_expectations
      end
    end

    attr_reader :hydra, :scope, :expectations, :successes, :failures, :base_path_builder

    def initialize(scope)
      @scope = scope
      Ethon.logger = Logger.new(nil) # disable Typhoeus/Ethon debug logging
      max_concurrency = Rails.env.development? ? 1 : 20
      @hydra = Typhoeus::Hydra.new(max_concurrency: max_concurrency)
      @expectations = []
      @successes = []
      @failures = []

      @base_path_builder = lambda do |model|
        if model.is_a?(Edition)
          Whitehall.url_maker.public_document_path(model)
        else
          Whitehall.url_maker.polymorphic_path(model)
        end
      end

      add_translations_expectation if can_have_translations?(scope.first)
    end

    def add_expectation(description, &block)
      expectations << { description: description, block: block }
    end

    def override_base_path(&base_path_builder)
      @base_path_builder = base_path_builder
    end

    def perform(output: true)
      scope.find_each do |whitehall_model|
        queue_check("content-store", whitehall_model, output)
        queue_check("draft-content-store", whitehall_model, output)
      end
      hydra.run
      print_results if output
    end

  private

    def queue_check(content_store, whitehall_model, output)
      url = Plek.find(content_store) + "/content" + base_path_for(whitehall_model)
      request = Typhoeus::Request.new(url)
      request.on_complete do |response|
        success = compare_content(response, whitehall_model, content_store)
        if output
          progress_indicator = success ? "." : "x"
          print progress_indicator
        end
      end
      hydra.queue(request)
    end

    def add_translations_expectation
      add_expectation("translations") do |_, record|
        translations_present_and_have_correct_basepath?(record)
      end
    end

    def translations_present_and_have_correct_basepath?(record)
      content_store = GdsApi::ContentStore.new(Plek.find("content-store"))
      translation_locales_for(record).each do |locale|
        base_path_for_translation = base_path_for(record, locale: locale)
        content_item = content_store.content_item(base_path_for_translation)
        return false if content_item.nil? || content_item["base_path"] != base_path_for_translation
      end
      true
    end

    def compare_content(response, whitehall_model, content_store)
      base_path = base_path_for(whitehall_model)
      if response.success?
        json = JSON.parse(response.body)
        failed_expectations = expectations.reject do |expectation|
          begin
            expectation[:block].call(json, whitehall_model)
          rescue => e
            failures << Failure.new(
              base_path: base_path,
              failed_expectations: ["raised error #{e.message}"],
              content_store: content_store
            )
            true # Already adding a Failure, no need to add another one later
          end
        end
        if failed_expectations.empty?
          successes << Success.new(base_path: base_path)
          success = true
        else
          failed_expectation_descriptions = failed_expectations.map { |expectation| expectation[:description] }
          failures << Failure.new(base_path: base_path, failed_expectations: failed_expectation_descriptions, content_store: content_store)
          success = false
        end
      else
        failures << Failure.new(
          base_path: base_path,
          failed_expectations: ["item unreachable, response status: #{response.status_message}"],
          content_store: content_store
        )
        success = false
      end
      success
    end

    def print_results
      successes.uniq!(&:base_path)
      failures.uniq!(&:base_path)
      puts "\nCheck complete"
      puts "Successes: #{successes.count}"
      puts "Failures: #{failures.count}"
      failures.each { |failure| puts failure.to_s } unless failures.empty?
    end

    def base_path_for(whitehall_model, locale: :en)
      I18n.with_locale(locale) do
        @base_path_builder.call(whitehall_model)
      end
    end

    def translation_locales_for(record)
      if can_have_translations?(record)
        record.translated_locales - [:en]
      else
        []
      end
    end

    def can_have_translations?(record)
      record.respond_to?(:translated_locales)
    end
  end
end
