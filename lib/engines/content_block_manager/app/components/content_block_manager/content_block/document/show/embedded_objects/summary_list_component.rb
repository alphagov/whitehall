class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryListComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::EmbedCodeHelper
  def initialize(content_block_edition:, object_type:, object_title:)
    @content_block_edition = content_block_edition
    @object_type = object_type
    @object_title = object_title
  end

private

  attr_reader :content_block_edition, :object_type, :object_title

  def summary_list_items
    object.keys.map { |key|
      rows = [
        {
          field: key.titleize,
          value: object[key],
          data: data_attributes_for_row(key),
        },
      ]
      rows.push(embed_code_row("#{object_type}/#{object_title}/#{key}", content_block_edition.document))
      rows
    }.flatten
  end

  def object
    content_block_edition.details.dig(object_type, object_title)
  end

  def data_attributes_for_row(key)
    { testid: (object_title.parameterize + "_#{key}").underscore }
  end
end
