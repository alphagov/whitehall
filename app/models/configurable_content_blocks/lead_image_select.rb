module ConfigurableContentBlocks
  class LeadImageSelect
    attr_reader :images, :default_lead_image

    def initialize(images = [], default_lead_image: nil)
      @images = images
      @default_lead_image = default_lead_image
    end

    def publishing_api_payload(content)
      if (selected_image = images.find { |image| image.image_data.id == content.to_i })
        {
          url: selected_image.url,
          caption: selected_image.caption,
        }
      end
    end

    def to_partial_path
      "admin/configurable_content_blocks/lead_image_select"
    end

    def rendered_image_url
      default_lead_image_url || placeholder_image_url
    end

  private

    def default_lead_image_url
      default_lead_image&.url(:s300)
    end

    def placeholder_image_url
      ActionController::Base.helpers.image_url("placeholder.jpg", host: Whitehall.public_root)
    end
  end
end
