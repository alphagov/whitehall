module FlexiblePageContentBlocks
  class DefaultString
    def json_schema_type
      "string"
    end

    def json_schema_format
      "default"
    end

    def publishing_api_payload(content)
      content
    end

    def render(property_schema, content, path = Path.new, required: false)
      Context.renderer.render "govuk_publishing_components/components/input", {
        id: path.form_control_id,
        label: { text: property_schema["title"] + (required ? " (required)" : "") },
        name: path.form_control_name,
        value: content,
        hint: property_schema["description"],
      }
    end
  end
end
