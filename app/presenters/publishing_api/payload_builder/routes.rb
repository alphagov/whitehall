module PublishingApi
  module PayloadBuilder
    class Routes
      attr_reader :base_path, :additional_routes

      def self.for(base_path, prefix: false, additional_routes: [])
        new(base_path, prefix:, additional_routes:).call
      end

      def initialize(base_path, prefix: false, additional_routes: [])
        @base_path = base_path
        @prefix = prefix
        @additional_routes = additional_routes
      end

      def call
        routes = []
        routes << { path: base_path, type: }
        additional_routes.each do |additional_route|
          routes << { path: "#{base_path}.#{additional_route}", type: "exact" }
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
