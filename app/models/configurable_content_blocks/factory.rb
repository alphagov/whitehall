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

    def build_all
      all_block_constructors = []
      blocks.values.each do |formats|
        all_block_constructors << formats.values
      end
      all_block_constructors.flatten.map { |constructor| constructor.call(@page) }
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
          "lead_image_select" => ->(page) { ConfigurableContentBlocks::LeadImageSelect.new(page.non_svg_images, default_lead_image: page.default_lead_image, is_world_news_story: page.configurable_document_type == "world_news_story") },
        },
        "object" => {
          "default" => ->(_page) { ConfigurableContentBlocks::DefaultObject.new(self) },
        },
      }.freeze
    end
  end
end
