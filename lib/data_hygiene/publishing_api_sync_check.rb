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
    attr_reader :hydra, :scope, :expectations, :successes, :failures, :base_path_builder

    def initialize(scope)
      @scope = scope
      Ethon.logger = Logger.new(nil) # disable Typhoeus/Ethon debug logging
      @hydra = Typhoeus::Hydra.new(max_concurrency: 20)
      @expectations = []
      @successes = []
      @failures = []

      @base_path_builder = lambda { |whitehall_model| Whitehall.url_maker.polymorphic_path(whitehall_model) }
    end

    def add_expectation(&block)
      expectations << block
    end

    def override_base_path(&base_path_builder)
      @base_path_builder = base_path_builder
    end

    def perform(output: true)
      scope.find_each do |whitehall_model|
        url = Plek.find('content-store') + "/content" + base_path_for(whitehall_model)
        request = Typhoeus::Request.new(url)
        request.on_complete do |response|
          print "." if output
          compare_content(response, whitehall_model)
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
        if expectations.all? { |expectation| expectation.call(json, whitehall_model) } # should return true if expectations is empty
          successes << base_path
        else
          failures << base_path
        end
      else
        failures << base_path
      end
    end

    def print_results
      puts "\nCheck complete"
      puts "Successes: #{successes.count}"
      puts "Failures: #{failures.count}"
      puts "Failure paths:\n#{failures.join("\n")}" unless failures.empty?
    end

    def base_path_for(whitehall_model)
      @base_path_builder.call(whitehall_model)
    end
  end
end
