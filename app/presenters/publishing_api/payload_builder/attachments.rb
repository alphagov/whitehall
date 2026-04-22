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
            attachments = item.attachments_ready_for_publishing
            # nil/"" locale should always be returned
            locales_that_match = [I18n.locale.to_s, ""]
            attachments.to_a.select { |attachment| locales_that_match.include?(attachment.locale.to_s) }.map(&:publishing_api_details)
          else
            []
          end
        end
      end
    end
  end
end
