module PublishingApi
  module PayloadBuilder
    class BodyHeadings
      include Presenters::PublishingApi::PayloadHeadingsHelper

      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        extract_headings(item.body)
      end
    end
  end
end
