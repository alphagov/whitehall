class ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent < ViewComponent::Base
  def initialize(content_block_edition:)
    @content_block_edition = content_block_edition
  end

private

  attr_reader :content_block_edition

  def items
    [
      edit_item,
      title_item,
      *details_items,
      organisation_item,
      instructions_item,
      *change_note_items,
      status_item,
    ].compact
  end

  def edit_item
    {
      field: "#{content_block_edition.document.block_type.humanize} details",
      edit: edit_action,
    }
  end

  def title_item
    {
      field: "Title",
      value: content_block_edition.title,
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

  def change_note_items
    return [] if content_block_edition.document.is_new_block?

    content_block_edition.major_change ? [internal_change_note_item, major_change_item, external_change_note_item] : [internal_change_note_item, major_change_item]
  end

  def internal_change_note_item
    {
      field: "Internal note",
      value: content_block_edition.internal_change_note.presence || "None",
      edit: {
        href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :internal_note),
        link_text: "Edit",
      },
    }
  end

  def major_change_item
    {
      field: "Do users have to know the content has changed?",
      value: content_block_edition.major_change ? "Yes" : "No",
      edit: {
        href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :change_note),
        link_text: "Edit",
      },
    }
  end

  def external_change_note_item
    {
      field: "Public change note",
      value: content_block_edition.change_note,
      edit: {
        href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :change_note),
        link_text: "Edit",
      },
    }
  end

  def edit_action
    {
      href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :edit_draft),
      link_text: "Edit",
    }
  end

  def scheduled_value
    I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)
  end

  def status_item
    if content_block_edition.scheduled_publication
      {
        field: "Scheduled date and time",
        value: scheduled_value,
      }
    elsif content_block_edition.document.editions.count > 1
      {
        field: "Publish date",
        value: I18n.l(Time.zone.today, format: :long_ordinal),
      }
    end
  end
end
