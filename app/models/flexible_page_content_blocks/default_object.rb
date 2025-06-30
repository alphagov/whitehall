module FlexiblePageContentBlocks
  class DefaultObject
    def json_schema_type
      "object"
    end

    def json_schema_format
      "default"
    end

    def publishing_api_payload(schema, content)
      output = {}
      schema["properties"].each do |property_key, property_schema|
        block = Factory.build(property_schema["type"], property_schema["format"] || "default")
        leaf_block = !%w[object array].include?(block.json_schema_type)
        payload = leaf_block ? block.publishing_api_payload(content[property_key]) : block.publishing_api_payload(property_schema, content[property_key])
        output.merge!({ property_key.to_sym => payload })
      end
      output
    end

    def render(schema, content, path = Path.new, required: false)
      Context.renderer.render("govuk_publishing_components/components/fieldset", {
        legend_text: if path.to_a.blank?
                       ""
                     else
                       schema["title"] + (required ? " (required)" : "")
                     end,
        heading_size: "m",
        id: path.form_control_id,
      }) do
        output = ""
        schema["properties"].each do |property_key, property_schema|
          block = Factory.build(property_schema["type"], property_schema["format"] || "default")
          safe_content = content && Context.renderer.sanitize(content[property_key])
          property_required = schema["required"]&.include?(property_key)
          output += block.render(property_schema, safe_content, path.push(property_key), required: property_required)
        end
        # Rails recommends using sanitize instead of html_safe, but it removes a lot of the HTML and I don't know why
        # html_safe is potentially dangerous if used with user input, so we're sanitizing the content
        # above before passing it to the child block
        output.html_safe
      end
    end
  end
end
