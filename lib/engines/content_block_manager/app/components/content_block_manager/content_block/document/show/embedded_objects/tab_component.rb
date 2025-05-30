class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabComponent < ViewComponent::Base
  def initialize(content_block_document:, subschemas:)
    @content_block_edition = content_block_document.latest_edition
    @subschemas = subschemas
  end

private

  attr_reader :content_block_edition, :subschemas

  def tabs
    subschemas.map do |subschema|
      {
        id: subschema.id,
        label: tab_label(subschema),
        content: tab_content(subschema),
      }
    end
  end

  def tab_label(subschema)
    "#{subschema.name.pluralize} (#{embedded_objects(subschema.id).count})"
  end

  def embedded_objects(object_type)
    content_block_edition.details.fetch(object_type, {})
  end

  def tab_content(subschema)
    html = ""
    html << add_button(subschema)
    embedded_objects(subschema.id).keys.map do |key|
      html <<
        render(
          ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabContentComponent.new(
            content_block_edition:,
            object_type: subschema.id,
            object_title: key,
          ),
        )
    end
    sanitize(html)
  end

  def add_button(subschema)
    render(
      "govuk_publishing_components/components/button",
      {
        text: "Add #{helpers.add_indefinite_article subschema.name.singularize.downcase}",
        href: helpers.content_block_manager.new_content_block_manager_content_block_document_embedded_object_path(
          content_block_edition.document,
          object_type: subschema.id,
        ),
        margin_bottom: 6,
      },
    )
  end
end
