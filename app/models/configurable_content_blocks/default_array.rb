module ConfigurableContentBlocks
  class DefaultArray
    include Renderable
    attr_reader :edition, :path

    def initialize(edition, config, path)
      @edition = edition
      @config = config
      @path = path
    end

    def title
      @config["title"]
    end

    def required
      @config["required"]
    end

    def field_blocks(index)
      @config["fields"].map do |field_key, field_config|
        ConfigurableContentBlocks::Factory.blocks[field_config["block"]].new(@edition, field_config, @path.push(index).push(field_key))
      end
    end

    def items
      @edition.block_content&.value_at(@path) or []
    end

    private def template_name
      "default_array"
    end
  end
end
