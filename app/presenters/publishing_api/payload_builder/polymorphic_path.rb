module PublishingApi
  module PayloadBuilder
    class PolymorphicPath
      attr_reader :item, :prefix, :additional_routes, :additional_paths

      def self.for(item, prefix: false, additional_routes: [], additional_paths: [])
        new(item, prefix:, additional_routes:, additional_paths:).call
      end

      def initialize(item, prefix: false, additional_routes: [], additional_paths: [])
        @item = item
        @prefix = prefix
        @additional_routes = additional_routes
        @additional_paths = additional_paths
      end

      def call
        { base_path: }.merge(
          PayloadBuilder::Routes.for(base_path, prefix:, additional_routes:, additional_paths:),
        )
      end

    private

      def base_path
        @base_path ||= item.public_path(locale: I18n.locale)
      end
    end
  end
end
