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
        # A conditionally_reveal block's own attribute_path is relative to the
        # selected item - e.g. an attribute_path of ["alternative_url"] on the
        # "scotland" item resolves to the full path
        # ["block_content", "nation_applicability", "scotland", "alternative_url"].
        ConfigurableDocumentType::CONTENT_BLOCKS[field_config["block"]].new(@edition, field_config, @path.push([item["value"], *field_config["attribute_path"]]))
      end
    end

  private

    def template_name
      "default_checkboxes"
    end
  end
end
