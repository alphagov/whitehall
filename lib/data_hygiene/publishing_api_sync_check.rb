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

      def initialize(base_path:, failed_expectations:)
        @base_path = base_path
        @failed_expectations = failed_expectations
      end

      def to_s
        "Failed path: #{@base_path}, failed expectations: #{@failed_expectations.join(', ')}"
      end

      def ==(other)
        self.base_path == other.base_path && self.failed_expectations == other.failed_expectations
      end
    end

    attr_reader :hydra, :scope, :expectations, :successes, :failures, :base_path_builder

    def initialize(scope)
      @scope = scope
      Ethon.logger = Logger.new(nil) # disable Typhoeus/Ethon debug logging
      @hydra = Typhoeus::Hydra.new(max_concurrency: 20)
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
    end

    def add_expectation(description, &block)
      expectations << { description: description, block: block }
    end

    def override_base_path(&base_path_builder)
      @base_path_builder = base_path_builder
    end

    def perform(output: true)
      scope.find_each do |whitehall_model|
        url = Plek.find('content-store') + "/content" + base_path_for(whitehall_model)
        request = Typhoeus::Request.new(url)
        request.on_complete do |response|
          success = compare_content(response, whitehall_model)
          if output
            progress_indicator = success ? "." : "x"
            print progress_indicator
          end
        end
        hydra.queue(request)
      end
      hydra.run
      print_results if output
    end

  private

    def compare_content(response, whitehall_model)
      base_path = base_path_for(whitehall_model)
      if response.success?
        json = JSON.parse(response.body)
        failed_expectations = expectations.reject { |expectation| expectation[:block].call(json, whitehall_model) }
        if failed_expectations.empty?
          successes << Success.new(base_path: base_path)
          success = true
        else
          failed_expectation_descriptions = failed_expectations.map { |expectation| expectation[:description] }
          failures << Failure.new(base_path: base_path, failed_expectations: failed_expectation_descriptions)
          success = false
        end
      else
        failures << Failure.new(base_path: base_path, failed_expectations: ["item missing from Content Store"])
        success = false
      end
      success
    end

    def print_results
      puts "\nCheck complete"
      puts "Successes: #{successes.count}"
      puts "Failures: #{failures.count}"
      failures.each { |failure| puts failure.to_s } unless failures.empty?
    end

    def base_path_for(whitehall_model)
      @base_path_builder.call(whitehall_model)
    end
  end
end
