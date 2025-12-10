module ConfigurableContentBlocks
  class ImageCard
    def to_partial_path
      "admin/configurable_content_blocks/image_card"
    end

    def publishing_api_payload(content)
      # Expecting content to be a hash with :image_data_id and :caption keys
      return nil if content.nil?

      if image_data(content) && image_data(content).all_asset_variants_uploaded?
        {
          url: image_data(content).file.url,
          caption: caption(content),
        }.compact
      end
    end

    def image_data(content)
      ImageData.where(id: content[:image_data_id].to_i)&.first
    end

    def caption(content)
      content && content[:caption]
    end

    def thumbnail_url(content)
      content && image_data(content)&.file.url(:s300)
    end
  end
end
