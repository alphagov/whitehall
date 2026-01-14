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
  end
end
