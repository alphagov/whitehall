module ConfigurableContentBlocks
  class DefaultSelect
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


    def hint_text
      @config["description"]
    end

    def required
      @config["required"]
    end

    def select_options
      [
        { text: @config["blank_option_label"] || "Select an option", value: "" },
      ] + @config["options"].map do |opt|
        {
          text: opt["label"],
          value: opt["value"],
          selected: opt["value"] == @edition.block_content.value_at(@path),
        }
      end
    end

    private def template_name
      "default_select"
    end
  end
end
