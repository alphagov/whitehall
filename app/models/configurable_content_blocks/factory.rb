module ConfigurableContentBlocks
  class Factory
    def initialize(page)
      @page = page
    end

    def build(type, format = "default")
      block_constructor = blocks.dig(type, format)
      raise "No block is defined for the #{type} type #{format} format" if block_constructor.nil?

      block_constructor.call(@page)
    end

  private

    def blocks
      {
        "string" => {
          "default" => ->(_page) { ConfigurableContentBlocks::DefaultString.new },
          "govspeak" => ->(page) { ConfigurableContentBlocks::Govspeak.new(page.images, page.attachments) },
        },
        "integer" => {
          # page.valid_images.where(imagekind: :header_image).id) },#  .first_or_initialize(caption: page.default_lead_image_caption)) },
          "image_card" => ->(_page) { ConfigurableContentBlocks::ImageCard.new },
          "image_select" => ->(page) { ConfigurableContentBlocks::ImageSelect.new(page.valid_images) },
          "lead_image_select" => ->(page) { ConfigurableContentBlocks::LeadImageSelect.new(page.valid_lead_images, default_lead_image: page.default_lead_image, placeholder_image_url: page.placeholder_image_url) },
        },
        "object" => {
          "default" => ->(_page) { ConfigurableContentBlocks::DefaultObject.new(self) },
          "wrapper" => ->(_page) { ConfigurableContentBlocks::WrapperObject.new(self) },
        },
        "date" => {
          "default" => ->(_page) { ConfigurableContentBlocks::DefaultDate.new },
        },
      }.freeze
    end
  end
end
