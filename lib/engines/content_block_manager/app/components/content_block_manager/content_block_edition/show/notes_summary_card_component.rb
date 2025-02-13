class ContentBlockManager::ContentBlockEdition::Show::NotesSummaryCardComponent < ViewComponent::Base
  def initialize(content_block_edition:)
    @content_block_edition = content_block_edition
  end

private

  attr_reader :content_block_edition

  def title
    "Notes"
  end

  def rows
    content_block_edition.major_change ? [internal_change_note_item, major_change_item, external_change_note_item] : [internal_change_note_item, major_change_item]
  end

  def internal_change_note_item
    {
      key: "Internal note",
      value: content_block_edition.internal_change_note.presence || "None",
      actions: [
        {
          label: "Edit",
          href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :internal_note),
        },
      ],
    }
  end

  def major_change_item
    {
      key: "Do users have to know the content has changed?",
      value: content_block_edition.major_change ? "Yes" : "No",
      actions: [
        {
          href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :change_note),
          label: "Edit",
        },
      ],
    }
  end

  def external_change_note_item
    {
      key: "Public change note",
      value: content_block_edition.change_note,
      actions:
        [
          {
            href: helpers.content_block_manager.content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :change_note),
            label: "Edit",
          },
        ],
    }
  end
end
