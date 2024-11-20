class ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent < ViewComponent::Base
  def initialize(content_block_edition:)
    @content_block_edition = content_block_edition
  end

private

  attr_reader :content_block_edition

  def items
    [
      edit_item,
      *details_items,
      organisation_item,
      instructions_item,
      confirm_item,
      date_item,
    ]
  end

  def edit_item
    {
      field: "#{content_block_edition.document.block_type.humanize} details",
      edit: edit_action,
    }
  end

  def details_items
    content_block_edition.details.map do |key, value|
      {
        field: "New #{key.humanize.downcase}",
        value:,
      }
    end
  end

  def organisation_item
    {
      field: "Lead organisation",
      value: content_block_edition.lead_organisation,
    }
  end

  def instructions_item
    {
      field: "Instructions to publishers",
      value: content_block_edition.instructions_to_publishers.presence || "None",
    }
  end

  def confirm_item
    {
      field: "Confirm",
      value: "I confirm that I am happy for the content block to be changed on these pages.",
    }
  end

  def date_item
    {
      field: "Publish date",
      value: I18n.l(content_block_edition.created_at.to_date, format: :long_ordinal),
    }
  end

  def edit_action
    {
      href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: ContentBlockManager::ContentBlock::Editions::WorkflowController::NEW_BLOCK_STEPS[:edit_draft]),
      link_text: "Edit",
    }
  end
end
