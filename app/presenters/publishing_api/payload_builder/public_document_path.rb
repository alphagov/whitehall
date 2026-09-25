module PublishingApi
  module PayloadBuilder
    class PublicDocumentPath
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        routes = if item.additional_routes.any?
                   PayloadBuilder::Routes.for(base_path, additional_routes: item.additional_routes)
                 else
                   PayloadBuilder::Routes.for(base_path)
                 end
        { base_path: }.merge(routes)
      end

    private

      def base_path
        @base_path ||= item.public_path(locale: I18n.locale)
      end
    end
  end
end
