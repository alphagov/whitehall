module ConfigurableContentBlocks
  class DefaultArray < BaseBlock
    include Enumerable

    def field_blocks(index)
      @config["fields"].values.map do |field_config|
        ConfigurableDocumentType::CONTENT_BLOCKS[field_config["block"]].new(@edition, field_config, @path.push([index, *field_config["attribute_path"]]))
      end
    end

    def add_another_button_text
      @config["add_another_button_text"] || "Add another"
    end

    def items
      value || []
    end

    def each(&block)
      block.call(self)
      items.map.with_index do |_item, index|
        field_blocks(index).each do |field_block|
          if field_block.respond_to? :each
            field_block.each(&block)
          else
            block.call(field_block)
          end
        end
      end
    end

    def each_leaf(&block)
      return enum_for(:each_leaf) unless block_given?

      items.each_with_index do |_item, index|
        field_blocks(index).each do |field_block|
          if field_block.respond_to? :each_leaf
            field_block.each_leaf(&block)
          else
            block.call(field_block)
          end
        end
      end
    end

  private

    def template_name
      "default_array"
    end
  end
end
