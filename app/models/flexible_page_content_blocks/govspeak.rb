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

    def render(property_schema, content, path = [], required: false)
      Context.renderer.render "govuk_publishing_components/components/textarea", {
        label: { text: property_schema["title"] + (required ? " (required)" : "") },
        name: "edition[flexible_page_content][#{path.join('][')}]",
        value: content,
        hint: property_schema["description"],
        textarea_id: "edition_flexible_page_content_#{path.join('_')}",
      }
    end
  end
end
