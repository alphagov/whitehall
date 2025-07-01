module FlexiblePageContentBlocks
  class ImageSelect
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

      if (selected_image = Context.page.images.find { |image| image.id == content.to_i })
        {
          src: selected_image.url,
          caption: selected_image.caption,
          alt_text: selected_image.alt_text,
        }
      else
        Rails.logger.warn("Flexible page with ID #{Context.page.id} does not have an image with ID #{content}, so the image has been excluded from the Publishing API payload.")
        nil
      end
    end

    def to_partial_path
      "admin/flexible_pages/content_blocks/image_select"
    end
  end
end
