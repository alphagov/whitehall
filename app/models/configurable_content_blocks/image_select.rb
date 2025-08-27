module ConfigurableContentBlocks
  class ImageSelect
    attr_reader :images

    def initialize(images = [])
      @images = images
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
      return nil if content.blank?

      if (selected_image = images.find { |image| image.image_data.id == content.to_i })
        {
          url: selected_image.url,
          caption: selected_image.caption,
        }
      else
        Rails.logger.warn("The page does not have an image with ID #{content}, so the image has been excluded from the Publishing API payload.")
        nil
      end
    end

    def to_partial_path
      "admin/configurable_content_blocks/image_select"
    end
  end
end
