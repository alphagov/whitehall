module PublishingApi
  module PayloadBuilder
    class BlockContent
      include GovspeakHelper

      def self.for(item)
        new(item).call
      end

      def initialize(item)
        @item = item
      end

      def call
        mapping = @item.type_instance.presenter("publishing_api")
        return {} unless mapping

        mapping.each_with_object({}) { |(attribute, builder), details|
          details[attribute.to_sym] = send(builder, attribute)
        }.compact
      end

    private

      attr_reader :item

      def govspeak(attribute)
        content = item.block_content&.public_send(attribute)
        return nil if content.nil?

        govspeak_to_html(content, images: item.images, attachments: item.attachments)
      end

      def rfc3339_date(attribute)
        item.block_content&.public_send(attribute)&.rfc3339
      end

      def image(attribute)
        content = item.block_content&.public_send(attribute)

        return nil if content.nil?

        selected_image = item.valid_images.find { |image| image.image_data.id == content }
        if selected_image&.image_data&.all_asset_variants_uploaded?
          {
            url: selected_image.url,
            caption: selected_image.caption&.strip.presence,
          }.compact
        end
      end

      def lead_image(attribute)
        content = item.block_content&.public_send(attribute)

        selected_image = item.valid_lead_images.find { |image| image.image_data.id == content }
        if selected_image
          if selected_image.image_data&.all_asset_variants_uploaded?
            # The payload for lead image must include a "high resolution url", used for metadata: https://github.com/alphagov/frontend/blob/693747dc55d9a42ba209789e6861d9b592b48c8e/spec/system/news_article_spec.rb#L65
            # The "url" is used for the lead image rendered on the document page.
            return {
              high_resolution_url: selected_image.image_data.url(:s960),
              url: selected_image.image_data.url(:s300),
              caption: selected_image&.caption&.strip.presence,
            }.compact
          end
        elsif item.default_lead_image&.all_asset_variants_uploaded?
          return {
            high_resolution_url: item.default_lead_image.url(:s960),
            url: item.default_lead_image.url(:s300),
          } # default images do no t have captions
        end

        # We are currently sending the same placeholder asset twice since front-end expects a url and a high-res url in the lead image payload. We don't have an additional asset in the correct size to send.
        {
          high_resolution_url: item.placeholder_image_url,
          url: item.placeholder_image_url,
        }
      end

      def string(attribute)
        item.block_content&.public_send(attribute)
      end
    end
  end
end
