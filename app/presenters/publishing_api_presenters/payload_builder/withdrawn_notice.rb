module PublishingApiPresenters
  module PayloadBuilder
    class WithdrawnNotice
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        return {} unless item.withdrawn?
        { withdrawn_notice: withdrawn_notice }
      end

    private

      def withdrawn_notice
        {
          explanation: unpublishing_explanation,
          withdrawn_at: item.updated_at
        }
      end

      def unpublishing_explanation
        if item.unpublishing.try(:explanation).present?
          Whitehall::GovspeakRenderer.new.govspeak_to_html(item.unpublishing.explanation)
        end
      end
    end
  end
end
