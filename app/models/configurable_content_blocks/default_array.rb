module ConfigurableContentBlocks
  class DefaultArray < BaseBlock
    include Renderable

    def field_blocks(index)
      @config["fields"].values.map do |field_config|
        ConfigurableDocumentType::CONTENT_BLOCKS[field_config["block"]].new(@edition, field_config, @path.push([index, *field_config["attribute_path"]]))
      end
    end

    def items
      value || []
    end

  private

    def template_name
      "default_array"
    end
  end
end
