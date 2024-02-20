module PublishingApi
  module PayloadBuilder
    class Routes
      attr_reader :base_path, :suffixes, :additional_routes

      def self.for(base_path, prefix: false, suffixes: [], additional_routes: [])
        new(base_path, prefix:, suffixes:, additional_routes:).call
      end

      def initialize(base_path, prefix: false, suffixes: [], additional_routes: [])
        @base_path = base_path
        @prefix = prefix
        @suffixes = suffixes
        @additional_routes = additional_routes
      end

      def call
        routes = []
        routes << { path: base_path, type: }
        suffixes.each do |suffix|
          routes << { path: "#{base_path}.#{suffix}", type: "exact" }
        end
        additional_routes.each do |additional_route|
          routes << { path: additional_route, type: "exact" }
        end
        { routes: }
      end

    private

      def type
        @prefix ? "prefix" : "exact"
      end
    end
  end
end
