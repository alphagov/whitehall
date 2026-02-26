module ConfigurableContentBlocks
  class DefaultSelect < BaseBlock
    include Renderable

    def select_options
      [
        { text: @config["blank_option_label"] || "Select an option", value: "" },
      ] + @config["options"].map do |opt|
        {
          text: opt["label"],
          value: opt["value"],
          selected: opt["value"] == value,
        }
      end
    end

  private

    def template_name
      "default_select"
    end
  end
end
