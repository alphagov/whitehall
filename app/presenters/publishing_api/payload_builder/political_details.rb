module PublishingApi
  module PayloadBuilder
    class PoliticalDetails
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        {
          political: item.political?,
        }
      end
    end
  end
end
