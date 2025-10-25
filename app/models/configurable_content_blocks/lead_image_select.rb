module ConfigurableContentBlocks
  class LeadImageSelect
    attr_reader :images, :default_lead_image

    def initialize(images = [], default_lead_image: nil)
      @images = images
      @default_lead_image = default_lead_image
    end

    def publishing_api_payload(content)
      selected_image = images.find { |image| image.image_data.id == content.to_i }
      if selected_image&.image_data&.all_asset_variants_uploaded?
        return {
          high_resolution_url: selected_image.image_data.url(:s960),
          url: selected_image.image_data.url(:s300),
          caption: lead_image_caption(selected_image),
        }.compact
      end

      if default_lead_image&.all_asset_variants_uploaded?
        {
          high_resolution_url: default_lead_image.url(:s960),
          url: default_lead_image.url(:s300),
        } # default images do not have captions
      end
    end

    def to_partial_path
      "admin/configurable_content_blocks/lead_image_select"
    end

    def rendered_default_image_url
      default_lead_image_url || placeholder_image_url
    end

  private

    def default_lead_image_url
      default_lead_image&.url(:s300)
    end

    def placeholder_image_url
      ActionController::Base.helpers.image_url("placeholder.jpg", host: Whitehall.public_root)
    end

    def lead_image_caption(image)
      caption = image&.caption&.strip
      caption.presence
    end
  end
end
