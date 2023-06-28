module PublishingApi
  module PayloadBuilder
    class CorporateInformationPage
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        {
          description: item.summary,
          rendering_app: item.rendering_app,
          public_updated_at:,
          details: {
            body:,
          },
        }
      end

    private

      def public_updated_at
        public_updated_at = item.public_timestamp ||
          item.updated_at

        public_updated_at.rfc3339
      end

      def body
        Whitehall::GovspeakRenderer
          .new
          .govspeak_edition_to_html(item)
      end
    end
  end
end
