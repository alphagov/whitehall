module PublishingApi
  module PayloadBuilder
    class PolymorphicPath
      attr_reader :item, :additional_routes

      def self.for(item, additional_routes: [])
        new(item, additional_routes: additional_routes).call
      end

      def initialize(item, additional_routes: [])
        @item = item
        @additional_routes = additional_routes
      end

      def call
        { base_path: base_path }.merge(
          PayloadBuilder::Routes.for(base_path, additional_routes: additional_routes)
        )
      end

    private

      def base_path
        @base_path ||= Whitehall.url_maker.polymorphic_path(item)
      end
    end
  end
end
