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
          "image_select" => ->(page) { ConfigurableContentBlocks::ImageSelect.new(page.images) },
          "lead_image_select" => ->(page) { ConfigurableContentBlocks::LeadImageSelect.new(page.non_svg_images, default_lead_image: page.default_lead_image) },
        },
        "object" => {
          "default" => ->(_page) { ConfigurableContentBlocks::DefaultObject.new(self) },
        },
      }.freeze
    end
  end
end
