module PublishingApi
  module PayloadBuilder
    class Images
      attr_reader :item

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        if images.any?
          { images: }
        else
          {}
        end
      end

      def images
        item.images
            .usable
            .usable_as(*item.permitted_image_usages.reject(&:embeddable?))
            .to_a
            .select { |image| image.image_data&.all_asset_variants_uploaded? }
            .map(&:publishing_api_details)
      end
    end
  end
end
