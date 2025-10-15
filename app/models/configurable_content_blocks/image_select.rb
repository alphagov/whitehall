module ConfigurableContentBlocks
  class ImageSelect
    attr_reader :images

    def initialize(images = [])
      @images = images
    end

    def publishing_api_payload(content)
      if (selected_image = images.find { |image| image.image_data.id == content.to_i })&.image_data&.all_asset_variants_uploaded?
        {
          url: selected_image.url,
          caption: image_caption(selected_image),
        }.compact
      end
    end

    def to_partial_path
      "admin/configurable_content_blocks/image_select"
    end

  private

    def image_caption(image)
      caption = image&.caption&.strip
      caption.presence
    end
  end
end
