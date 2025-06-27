module FlexiblePageContentBlocks
  class Factory
    BLOCKS = {
      "string" => {
        "default" => FlexiblePageContentBlocks::DefaultString,
        "govspeak" => FlexiblePageContentBlocks::Govspeak,
        "image_select" => FlexiblePageContentBlocks::ImageSelect,
      },
      "object" => {
        "default" => FlexiblePageContentBlocks::DefaultObject,
      },
    }.freeze
    private_constant :BLOCKS

    def self.build(type, format)
      block_class = BLOCKS.dig(type, format)
      raise "No block is defined for the #{type} type #{format} format" if block_class.blank?

      block_class.new
    end

    def self.build_all
      all_block_classes = []
      BLOCKS.values.each do |formats|
        all_block_classes << formats.values
      end
      all_block_classes.flatten.map(&:new)
    end
  end
end
