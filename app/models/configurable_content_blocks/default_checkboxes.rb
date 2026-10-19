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

  private

    def template_name
      "default_checkboxes"
    end
  end
end
