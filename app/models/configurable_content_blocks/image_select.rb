module ConfigurableContentBlocks
  class ImageSelect
    attr_reader :images

    def initialize(images = [])
      @images = images
    end

    def publishing_api_payload(content)
      if (selected_image = images.find { |image| image.image_data.id == content })
        {
          url: selected_image.url,
          caption: selected_image.caption,
        }
      end
    end

    def to_partial_path
      "admin/configurable_content_blocks/image_select"
    end
  end
end
