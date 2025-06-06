class ContentBlockManager::ContentBlock::Document::Show::SummaryCardComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::EditionHelper
  include ContentBlockManager::ContentBlock::EmbedCodeHelper

  def initialize(content_block_document:)
    @content_block_document = content_block_document
  end

private

  attr_reader :content_block_document

  def rows
    [
      title_item,
      *details_items,
      organisation_item,
      instructions_item,
      status_item,
    ].compact
  end

  def title
    "#{content_block_document.block_type.humanize} details"
  end

  def title_item
    {
      key: "Title",
      value: content_block_document.title,
    }
  end

  def organisation_item
    {
      key: "Lead organisation",
      value: content_block_edition.lead_organisation,
    }
  end

  def instructions_item
    {
      key: "Instructions to publishers",
      value: formatted_instructions_to_publishers(content_block_edition),
    }
  end

  def details_items
    schema.fields.map { |field|
      key = field.name
      rows = [{
        key: key.humanize,
        value: content_block_edition.details[key],
        data: data_attributes_for_row(key),
      }]
      rows.push(embed_code_row(key, content_block_document)) if should_show_embed_code?(key)
      rows
    }.flatten
  end

  def data_attributes_for_row(key)
    copy_embed_code_data_attributes(key, content_block_document) if should_show_embed_code?(key)
  end

  def should_show_embed_code?(key)
    embeddable_fields.include?(key)
  end

  def schema
    @schema ||= content_block_document.schema
  end

  def embeddable_fields
    @embeddable_fields = schema.embeddable_fields
  end

  def status_item
    if content_block_edition.state == "scheduled"
      {
        key: "Status",
        value: scheduled_value,
        actions: [
          {
            label: sanitize("Edit <span class='govuk-visually-hidden'>schedule</span>"),
            href: helpers.content_block_manager.content_block_manager_content_block_document_schedule_edit_path(content_block_document),
          },
        ],
      }
    else
      {
        key: "Status",
        value: last_updated_value,
      }
    end
  end

  def last_updated_value
    "Published on #{published_date(content_block_edition)} by #{content_block_edition.creator.name}".html_safe
  end

  def scheduled_value
    "Scheduled for publication at #{scheduled_date(content_block_edition)}".html_safe
  end

  def content_block_edition
    @content_block_edition = content_block_document.latest_edition
  end
end
