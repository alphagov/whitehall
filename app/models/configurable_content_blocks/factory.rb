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

    def build_block(block)
      blocks = {
        "default_string" => ->(_page) { ConfigurableContentBlocks::DefaultString.new },
        "govspeak" => ->(page) { ConfigurableContentBlocks::Govspeak.new(page.images, page.attachments) },
        "default_date" => ->(_page) { ConfigurableContentBlocks::DefaultDate.new },
        "image_select" => ->(page) { ConfigurableContentBlocks::ImageSelect.new(page.valid_images) },
        "lead_image_select" => ->(page) { ConfigurableContentBlocks::LeadImageSelect.new(page.valid_lead_images, default_lead_image: page.default_lead_image, placeholder_image_url: page.placeholder_image_url) },
        "default_object" => ->(_page) { ConfigurableContentBlocks::DefaultObject.new(self) },
      }.freeze

      raise "Block #{block} is not defined" if blocks[block].nil?

      blocks[block].call(@page)
    end

  private

    def blocks
      {
        "string" => {
          "default" => ->(_page) { ConfigurableContentBlocks::DefaultString.new },
          "govspeak" => ->(page) { ConfigurableContentBlocks::Govspeak.new(page.images, page.attachments) },
        },
        "integer" => {
          "image_select" => ->(page) { ConfigurableContentBlocks::ImageSelect.new(page.valid_images) },
          "lead_image_select" => ->(page) { ConfigurableContentBlocks::LeadImageSelect.new(page.valid_lead_images, default_lead_image: page.default_lead_image, placeholder_image_url: page.placeholder_image_url) },
        },
        "object" => {
          "default" => ->(_page) { ConfigurableContentBlocks::DefaultObject.new(self) },
        },
        "date" => {
          "default" => ->(_page) { ConfigurableContentBlocks::DefaultDate.new },
        },
      }.freeze
    end
  end
end
