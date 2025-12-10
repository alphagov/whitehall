module ConfigurableContentBlocks
  class ImageCard
    attr_reader :image

    def initialize(image)
      @image = image
    end

    def to_partial_path
      "admin/configurable_content_blocks/image_card"
    end

    # content could be an hash with url and the caption
    def publishing_api_payload(content)
      return nil if content.nil?

      if (selected_image = image&.image_data&.all_asset_variants_uploaded?)
        {
          url: selected_image.url,
          caption: image_caption(selected_image),
        }.compact
      end
    end

    def thumbnail_url(content)
      ImageData.find_by(id: image.id.to_i)
    end
  end
end
