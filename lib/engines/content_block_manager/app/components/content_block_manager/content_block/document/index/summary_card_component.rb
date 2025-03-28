class ContentBlockManager::ContentBlock::Document::Index::SummaryCardComponent < ViewComponent::Base
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
      status_item,
      (instructions_item if content_block_document.latest_edition.instructions_to_publishers.present?),
    ].compact
  end

  def title_item
    {
      key: "Title",
      value: content_block_document.title,
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

  def organisation_item
    {
      key: "Lead organisation",
      value: content_block_edition.lead_organisation,
    }
  end

  def status_item
    if content_block_edition.state == "scheduled"
      {
        key: "Status",
        value: scheduled_value,
        edit: {
          href: helpers.content_block_manager.content_block_manager_content_block_document_schedule_edit_path(content_block_document),
          link_text: sanitize("Edit <span class='govuk-visually-hidden'>schedule</span>"),
          link_text_no_enhance: true,
        },
      }
    else
      {
        key: "Status",
        value: last_updated_value,
      }
    end
  end

  def instructions_item
    {
      key: "Instructions to publishers",
      value: content_block_edition.instructions_to_publishers.presence || "None",
    }
  end

  def title
    content_block_document.title
  end

  def summary_card_actions
    [
      {
        label: "View",
        href: helpers.content_block_manager.content_block_manager_content_block_document_path(content_block_document),
      },
    ]
  end

  def content_block_edition
    @content_block_edition = content_block_document.latest_edition
  end

  def last_updated_value
    "Published on #{published_date(content_block_edition)} by #{content_block_edition.creator.name}".html_safe
  end

  def scheduled_value
    "Scheduled for publication at #{scheduled_date(content_block_edition)}".html_safe
  end
end
