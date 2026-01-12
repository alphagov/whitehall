module ConfigurableContentBlocks
  class ImageSelect
    attr_reader :images

    def initialize(images = [])
      @images = images
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
