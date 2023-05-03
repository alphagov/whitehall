module PublishingApi
  module PayloadBuilder
    class PolymorphicPath
      attr_reader :item, :prefix, :additional_routes

      def self.for(item, prefix: false, additional_routes: [])
        new(item, prefix:, additional_routes:).call
      end

      def initialize(item, prefix: false, additional_routes: [])
        @item = item
        @prefix = prefix
        @additional_routes = additional_routes
      end

      def call
        { base_path: }.merge(
          PayloadBuilder::Routes.for(base_path, prefix:, additional_routes:),
        )
      end

    private

      def base_path
        @base_path ||= if item.respond_to?(:public_path)
                         item.public_path(locale: I18n.locale)
                       else
                         Whitehall.url_maker.polymorphic_path(item)
                       end
      end
    end
  end
end
