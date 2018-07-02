module PublishingApi
  module PayloadBuilder
    class Routes
      attr_reader :base_path, :additional_routes

      def self.for(base_path, additional_routes: [])
        new(base_path, additional_routes: additional_routes).call
      end

      def initialize(base_path, additional_routes: [])
        @base_path = base_path
        @additional_routes = additional_routes
      end

      def call
        routes = []
        routes << { path: base_path, type: "exact" }
        additional_routes.each do |additional_route|
          routes << { path: "#{base_path}.#{additional_route}", type: "exact" }
        end
        { routes: routes }
      end
    end
  end
end
