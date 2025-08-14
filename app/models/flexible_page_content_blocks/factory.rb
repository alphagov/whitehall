module FlexiblePageContentBlocks
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
          "default" => ->(_page) { FlexiblePageContentBlocks::DefaultString.new },
          "govspeak" => ->(page) { FlexiblePageContentBlocks::Govspeak.new(page.images) },
          "image_select" => ->(page) { FlexiblePageContentBlocks::ImageSelect.new(page.images) },
        },
        "object" => {
          "default" => ->(_page) { FlexiblePageContentBlocks::DefaultObject.new(self) },
        },
      }.freeze
    end
  end
end
