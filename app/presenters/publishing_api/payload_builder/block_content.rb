module PublishingApi
  module PayloadBuilder
    class BlockContent
      include GovspeakHelper
      def self.for(item)
        self.new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        mapping = @item.type_instance.presenter("publishing_api")
        return {} unless mapping

        mapping.each_with_object({}) do |(attribute, builder), details|
          details[attribute] = send(builder, attribute)
        end
      end

    private

      attr_reader :item
      def govspeak(attribute)
        content = item.block_content.public_send(attribute)
        return nil if content.nil?

        govspeak_to_html(content, images: item.images, attachments: item.attachments)
      end

      def rfc3339_date(attribute)
        item.block_content.public_send(attribute).rfc3339
      end

      def image(attribute)
        content = item.block_content.public_send(attribute)
        return nil if content.nil?

        selected_image = item.valid_images.find { |image| image.image_data.id == content }
        if selected_image&.image_data&.all_asset_variants_uploaded?
          {
            url: selected_image.url,
            caption: selected_image.caption&.strip.presence,
          }.compact
        end
      end
    end
  end
end