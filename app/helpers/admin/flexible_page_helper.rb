module Admin::FlexiblePageHelper
  def render_flexible_page_content_fields(schema_properties, edition, path = "", output_html = "")
    schema_properties.each do |key, property|
      next_path = path.empty? ? key : "#{path}.#{key}"
      case property["type"]
      when "string"
        output_html += render "govuk_publishing_components/components/input", {
          label: {
            text: property["title"],
          },
          name: "edition[flexible_page_content][#{next_path.split('.').join('][')}]",
          value: edition.flexible_page_content&.dig(*next_path.split(".")) || "",
          id: "edition_flexible_page_content_#{next_path.split('.').join('_')}",
          hint: property["description"],
        }
      when "object"
        output_html += render "govuk_publishing_components/components/fieldset", {
          legend_text: property["title"],
          heading_size: "m",
          id: "edition_flexible_page_content_#{next_path.split('.').join('_')}",
        } do
          render inline: render_flexible_page_content_fields(property["properties"], edition, next_path, output_html)
        end
      end
    end
    output_html
  end
end
