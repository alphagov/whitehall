module Admin::FlexiblePageHelper
  def render_flexible_page_content_fields(schema, edition, path = [], output_html = "")
    schema["properties"].each do |key, property|
      next_path = [*path, key]
      output_html += render_field(property, schema, next_path, edition)
    end
    output_html
  end

private

  def render_field(property, schema, path, edition)
    field_attrs = build_field_attributes(property, schema, path, edition)

    case property["type"]
    when "string"
      component = property["format"] == "govspeak" ? "textarea" : "input"
      render "govuk_publishing_components/components/#{component}", field_attrs
    when "object"
      render "govuk_publishing_components/components/fieldset", {
        legend_text: property["title"],
        heading_size: "m",
        id: field_attrs[:id],
      } do
        render inline: render_flexible_page_content_fields(property, edition, path, "")
      end
    else
      raise "Unsupported property type: #{property['type']}"
    end
  end

  def build_field_attributes(property, schema, path, edition)
    required_suffix = schema["required"]&.include?(path.last.to_s) ? " (required)" : ""

    {
      label: { text: property["title"] + required_suffix },
      name: "edition[flexible_page_content][#{path.join('][')}]",
      value: edition.flexible_page_content&.dig(*path) || "",
      id: "edition_flexible_page_content_#{path.join('_')}",
      hint: property["description"],
    }
  end
end
