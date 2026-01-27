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
        embeddable_image_kinds = Whitehall.image_kinds.values.select { |image_kind| image_kind.permitted_uses.include?("govspeak_embed") }.map(&:name)

        item.images
            .usable
            .of_kind(*(item.permitted_image_kinds.map(&:name) - embeddable_image_kinds))
            .to_a
            .select { |image| image.image_data&.all_asset_variants_uploaded? }
            .map(&:publishing_api_details)
      end
    end
  end
end
