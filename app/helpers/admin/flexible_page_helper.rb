module Admin::FlexiblePageHelper
  def render_flexible_page_content_fields(schema, edition, path = [], output_html = "")
    schema["properties"].each do |key, property|
      next_path = [*path, key]
      case property["type"]
      when "string"
        output_html += render "govuk_publishing_components/components/input", {
          label: {
            text: property["title"] + (schema["required"] ? " (required)" : ""),
          },
          name: "edition[flexible_page_content][#{next_path.join('][')}]",
          value: edition.flexible_page_content&.dig(*next_path) || "",
          id: "edition_flexible_page_content_#{next_path.join('_')}",
          hint: property["description"],
        }
      when "object"
        output_html += render "govuk_publishing_components/components/fieldset", {
          legend_text: property["title"],
          heading_size: "m",
          id: "edition_flexible_page_content_#{next_path.join('_')}",
        } do
          render inline: render_flexible_page_content_fields(property, edition, next_path, output_html)
        end
      end
    end
    output_html
  end
end
