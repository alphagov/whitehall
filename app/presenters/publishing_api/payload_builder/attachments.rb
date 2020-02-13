module PublishingApi
  module PayloadBuilder
    class Attachments
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        {
          attachments: item.attachments.map(&:publishing_api_details),
        }
      end
    end
  end
end
