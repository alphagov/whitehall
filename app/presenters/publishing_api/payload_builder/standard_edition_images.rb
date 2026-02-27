module PublishingApi
  module PayloadBuilder
    class StandardEditionImages
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        payload = {}
        if (lead_image_usage = item.permitted_image_usages.find(&:lead?)).present?
          lead_image = item.lead_image_payload(lead_image_usage)
          payload[:image] = lead_image if lead_image.present?
        end
        payload[:images] = images if images.any?
        payload
      end

    private

      def images
        item.images
            .usable
            .usable_as(*item.permitted_image_usages.reject { |usage| usage.embeddable? || usage.lead? })
            .to_a
            .select { |image| image.image_data&.all_asset_variants_uploaded? }
            .map(&:publishing_api_details)
      end
    end
  end
end
