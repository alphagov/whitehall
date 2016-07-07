module PublishingApiPresenters
  module PayloadBuilder
    class PublicDocumentPath
      attr_reader :item

      def self.for(item)
        new(item).for
      end

      def initialize(item)
        @item = item
      end

      def for
        {
          base_path: base_path,
          routes: routes
        }
      end

    private

      def base_path
        Whitehall.url_maker.public_document_path(item, locale: I18n.locale)
      end

      def routes
        [{ path: base_path, type: "exact" }]
      end
    end
  end
end
