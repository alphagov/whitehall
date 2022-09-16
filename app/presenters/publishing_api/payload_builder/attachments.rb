module PublishingApi
  module PayloadBuilder
    class Attachments
      attr_reader :items

      def self.for(items)
        items = [items] unless items.is_a? Array
        new(items).call
      end

      def initialize(items)
        @items = items
      end

      def call
        { attachments: }
      end

      def attachments
        items.flat_map do |item|
          if item
            item.attachments.map(&:publishing_api_details)
          else
            []
          end
        end
      end
    end
  end
end
