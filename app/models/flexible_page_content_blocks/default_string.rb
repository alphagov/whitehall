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

    def render(property_schema, content, path = [], required: false)
      Context.renderer.render "govuk_publishing_components/components/input", {
        id: "edition_flexible_page_content_#{path.join('_')}",
        label: { text: property_schema["title"] + (required ? " (required)" : "") },
        name: "edition[flexible_page_content][#{path.join('][')}]",
        value: content,
        hint: property_schema["description"],
      }
    end
  end
end
