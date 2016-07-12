module PublishingApi
  module PayloadBuilder
    class AnalyticsIdentifier
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        { analytics_identifier: item.analytics_identifier }
      end
    end
  end
end
