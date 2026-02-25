module ConfigurableContentBlocks
  class DefaultObject < BaseBlock
    include Renderable

    def root?
      @config["root"]
    end

    def field_blocks
      @config["fields"].values.map do |field_config|
        ConfigurableDocumentType::CONTENT_BLOCKS[field_config["block"]].new(@edition, field_config, @path.push(field_config["attribute_path"]))
      end
    end

  private

    def template_name
      "default_object"
    end
  end
end
