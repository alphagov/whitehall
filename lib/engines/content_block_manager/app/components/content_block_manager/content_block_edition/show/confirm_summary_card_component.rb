class ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryCardComponent < ViewComponent::Base
  def initialize(content_block_edition:)
    @content_block_edition = content_block_edition
  end

private

  attr_reader :content_block_edition

  def title
    "#{content_block_edition.document.block_type.humanize} details"
  end

  def rows
    [
      title_item,
      *details_items,
      organisation_item,
      instructions_item,
    ].compact
  end

  def title_item
    {
      key: "Title",
      value: content_block_edition.title,
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

  def instructions_item
    {
      key: "Instructions to publishers",
      value: content_block_edition.instructions_to_publishers.presence || "None",
    }
  end

  def summary_card_actions
    [
      {
        label: "Edit",
        href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :edit_draft),
      },
    ]
  end
end
