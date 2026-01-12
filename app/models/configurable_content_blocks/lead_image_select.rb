module ConfigurableContentBlocks
  class LeadImageSelect
    attr_reader :images, :default_lead_image, :placeholder_image_url

    def initialize(images = [], default_lead_image: nil, placeholder_image_url: nil)
      @images = images
      @placeholder_image_url = placeholder_image_url
      @default_lead_image = default_lead_image
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
