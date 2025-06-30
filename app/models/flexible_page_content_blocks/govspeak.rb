module FlexiblePageContentBlocks
  class Govspeak
    def json_schema_type
      "string"
    end

    def json_schema_format
      "govspeak"
    end

    def json_schema_validator
      proc do |instance|
        instance.is_a?(String) && ::Govspeak::HtmlValidator.new(instance).valid?
      end
    end

    def publishing_api_payload(content)
      Whitehall::GovspeakRenderer.new.govspeak_to_html(content)
    end

    def render(property_schema, content, path = Path.new, required: false)
      Context.renderer.render "govuk_publishing_components/components/textarea", {
        label: {
          text: property_schema["title"] + (required ? " (required)" : ""),
          heading_size: "m",
        },
        name: path.form_control_name,
        value: content,
        hint: property_schema["description"],
        textarea_id: path.form_control_id,
      }
    end
  end
end
