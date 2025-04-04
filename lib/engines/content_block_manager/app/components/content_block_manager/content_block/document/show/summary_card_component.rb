class ContentBlockManager::ContentBlock::Document::Show::SummaryCardComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::EditionHelper

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
      value: content_block_edition.instructions_to_publishers.presence || "None",
    }
  end

  def details_items
    content_block_edition.first_class_details.map do |key, value|
      {
        key: key.humanize,
        value:,
      }
    end
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
