module ConfigurableContentBlocks
  class DefaultObject < BaseBlock
    include Enumerable

    def root?
      @config["root"]
    end

    def field_blocks
      @config["fields"].values.map do |field_config|
        ConfigurableDocumentType::CONTENT_BLOCKS[field_config["block"]].new(@edition, field_config, @path.push(field_config["attribute_path"]))
      end
    end

    def each(&block)
      block.call(self)
      field_blocks.each do |field_block|
        if field_block.respond_to? :each
          field_block.each(&block)
        else
          block.call(field_block)
        end
      end
    end

  private

    def template_name
      "default_object"
    end
  end
end
