module ConfigurableContentBlocks
  class DefaultCheckboxes < BaseBlock
    def selected_path
      @path.push("selected")
    end

    def selected
      value&.dig("selected") || []
    end

    def items
      @config["items"] || []
    end

    def checked?(item)
      selected.include?(item["value"])
    end

    def conditional_field_blocks(item)
      (item["conditionally_reveal"] || []).map do |field_config|
        ConfigurableDocumentType::CONTENT_BLOCKS[field_config["block"]].new(@edition, field_config, @path.push([item["value"], *field_config["attribute_path"]]))
      end
    end

  private

    def template_name
      "default_checkboxes"
    end
  end
end
