class Document::PaginatedTimeline::ChangeNoteDecorator < SimpleDelegator
  def initialize(edition, is_first_published_edition: false)
    @is_first_published_edition = is_first_published_edition
    super(edition)
  end

  def ==(other)
    self.class == other.class && id == other.id
  end

  def created_at
    major_change_published_at
  end

  def note
    return change_note if change_note.present?

    "First published." if @is_first_published_edition
  end

  def actor
    published_by
  end

  def is_for_newer_edition?(edition)
    id > edition.id
  end

  def is_for_current_edition?(edition)
    id == edition.id
  end

  def is_for_older_edition?(edition)
    id < edition.id
  end
end
