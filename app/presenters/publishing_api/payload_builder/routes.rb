module PublishingApi
  module PayloadBuilder
    class Routes
      attr_reader :base_path, :additional_routes, :additional_paths

      def self.for(base_path, prefix: false, additional_routes: [], additional_paths: [])
        new(base_path, prefix:, additional_routes:, additional_paths:).call
      end

      def initialize(base_path, prefix: false, additional_routes: [], additional_paths: [])
        @base_path = base_path
        @prefix = prefix
        @additional_routes = additional_routes
        @additional_paths = additional_paths
      end

      def call
        routes = []
        routes << { path: base_path, type: }
        additional_routes.each do |additional_route|
          routes << { path: "#{base_path}.#{additional_route}", type: "exact" }
        end
        additional_paths.each do |additional_route|
          routes << { path: "#{base_path}/#{additional_route}", type: "exact" }
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
