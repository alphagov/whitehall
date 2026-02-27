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
        lead_usage = item.permitted_image_usages.find(&:lead?)
        lead_image = lead_usage && item.lead_image_payload(lead_usage)
        all_images = [lead_image, *images].compact

        all_images.any? ? { images: all_images } : {}
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
