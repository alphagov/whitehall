module FlexiblePageContentBlocks
  class ImageSelect
    def json_schema_type
      "string"
    end

    def json_schema_format
      "image_select"
    end

    def json_schema_validator
      proc do |instance|
        next true if instance.blank?

        instance.to_i.positive?
      end
    end

    def publishing_api_payload(content)
      return nil if content.blank?

      if (selected_image = Context.page.images.find { |image| image.id == content.to_i })
        {
          src: selected_image.url,
          caption: selected_image.caption,
          alt_text: selected_image.alt_text,
        }
      else
        Rails.logger.warn("Flexible page with ID #{Context.page.id} does not have an image with ID #{content}, so the image has been excluded from the Publishing API payload.")
        nil
      end
    end

    def render(property_schema, content, path = [], required: false)
      Context.renderer.render "govuk_publishing_components/components/select", {
        id: "edition_flexible_page_content_#{path.join('_')}]",
        label: property_schema["title"] + (required ? " (required)" : ""),
        name: "edition[flexible_page_content][#{path.join('][')}]",
        options: select_options(content),
        hint: property_schema["description"],
      }
    end

  private

    def select_options(content)
      [
        {
          text: "No image selected",
          value: "",
        },
      ] + Context.page.images.map do |image|
        {
          text: image.filename,
          value: image.id,
          selected: image.id == content.to_i,
        }
      end
    end
  end
end
