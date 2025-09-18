module ConfigurableContentBlocks
  class ImageSelect
    attr_reader :images, :default_lead_image

    def initialize(images = [], default_lead_image: nil)
      @images = images
      @default_lead_image = default_lead_image
    end

    def json_schema_type
      "string"
    end

    def json_schema_format
      "image_select"
    end

    def json_schema_validator
      proc do |instance|
        next true if instance.blank?

        instance.to_i.positive?
      end
    end

    def publishing_api_payload(content)
      return nil if content.blank? && !lead_image?

      # No custom image selection, sends default lead image if enabled
      # No caption is sent for the default as we do not set it on the organisation page
      if content.blank? && lead_image? && default_lead_image&.all_asset_variants_uploaded?
        return {
          high_resolution_url: high_resolution_lead_image_url(default_lead_image),
          url: lead_image_url(default_lead_image),
        }
      end

      # There is a custom image selection, send the selected image, either as a lead image or a standard image
      if (selected_image = images.find { |image| image.image_data.id == content.to_i }) && selected_image&.image_data&.all_asset_variants_uploaded?
        {
          high_resolution_url: lead_image? ? high_resolution_lead_image_url(selected_image.image_data) : nil,
          url: lead_image? ? lead_image_url(selected_image.image_data) : selected_image.url,
          caption: selected_image.caption,
        }.compact
      else
        Rails.logger.warn("The page does not have an image with ID #{content}, so the image has been excluded from the Publishing API payload.")
        nil
      end
    end

    def to_partial_path
      "admin/configurable_content_blocks/image_select"
    end

    def default_lead_image_url
      lead_image_url(default_lead_image)
    end

  private

    def lead_image?
      !default_lead_image.nil?
    end

    def lead_image_url(image_data)
      image_data&.file&.url(:s300)
    end

    def high_resolution_lead_image_url(image_data)
      image_data&.file&.url(:s960)
    end
  end
end
