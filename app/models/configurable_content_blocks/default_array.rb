module ConfigurableContentBlocks
  class DefaultArray
    include Renderable
    include BaseConfig
    attr_reader :edition, :path

    def initialize(edition, config, path)
      @edition = edition
      @config = config
      @path = path
    end

    def field_blocks(index)
      @config["fields"].map do |field_key, field_config|
        ConfigurableDocumentType::CONTENT_BLOCKS[field_config["block"]].new(@edition, field_config, @path.push(index).push(field_key))
      end
    end

    def items
      @edition.block_content&.value_at(@path) || []
    end

  private

    def template_name
      "default_array"
    end
  end
end
