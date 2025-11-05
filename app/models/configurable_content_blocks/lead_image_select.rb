module ConfigurableContentBlocks
  class LeadImageSelect
    attr_reader :images, :default_lead_image, :placeholder_image_url

    def initialize(images = [], default_lead_image: nil, placeholder_image_url: nil)
      @images = images
      @placeholder_image_url = placeholder_image_url
      @default_lead_image = default_lead_image
    end

    def publishing_api_payload(content)
      selected_image = images.find { |image| image.image_data.id == content.to_i }
      if selected_image
        if selected_image.image_data&.all_asset_variants_uploaded?
          # The payload for lead image must include a "high resolution url", used for metadata: https://github.com/alphagov/frontend/blob/693747dc55d9a42ba209789e6861d9b592b48c8e/spec/system/news_article_spec.rb#L65
          # The "url" is used for the lead image rendered on the document page.
          return {
            high_resolution_url: selected_image.image_data.url(:s960),
            url: selected_image.image_data.url(:s300),
            caption: lead_image_caption(selected_image),
          }.compact
        end
      elsif default_lead_image&.all_asset_variants_uploaded?
        return {
          high_resolution_url: default_lead_image.url(:s960),
          url: default_lead_image.url(:s300),
        } # default images do not have captions
      end

      placeholder_payload
    end

    def to_partial_path
      "admin/configurable_content_blocks/lead_image_select"
    end

    def rendered_default_image_url
      default_lead_image_url || placeholder_image_url
    end

  private

    def default_lead_image_url
      default_lead_image&.url(:s300) if default_lead_image&.all_asset_variants_uploaded?
    end

    def placeholder_payload
      # We are currently sending the same placeholder asset twice since front-end expects a url and a high-res url in the lead image payload. We don't have an additional asset in the correct size to send.
      {
        high_resolution_url: placeholder_image_url,
        url: placeholder_image_url,
      }
    end

    def lead_image_caption(image)
      caption = image&.caption&.strip
      caption.presence
    end
  end
end
