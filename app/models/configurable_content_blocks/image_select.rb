module ConfigurableContentBlocks
  class ImageSelect
    attr_reader :images, :path, :type_config, :type_properties, :content, :translated_content

    def initialize(edition, path, translated_edition = nil)
      @images = edition.images
      @path = path
      @type_config = edition.class.config
      @type_properties = edition.class.properties
      @content = path.to_a.inject(edition.block_content) do |content, segment|
        content.present? ? content.public_send(segment) : nil
      end
      @translated_content = path.to_a.inject(translated_edition.block_content) do |content, segment|
        content.present? ? content.public_send(segment) : nil
      end unless translated_edition.nil?
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
