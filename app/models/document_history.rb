class DocumentHistory
  attr_reader :document

  class Change < Struct.new(:public_timestamp, :note)
  end

  def initialize(document)
    @document = document
  end

  def changes
    return [] unless first_public_edition.present?

    subsequent_changes + [first_change]
  end

  def newly_published?
    changes.size == 1
  end

  def most_recent_change
    changes.first.public_timestamp
  end

  def empty?
    changes.empty?
  end

  private

  def first_change
    @first_change ||= Change.new(first_published_at, first_public_edition_note)
  end

  def subsequent_changes
    @subsequent_changes ||= subsequent_major_editions.map { |edition| Change.new(edition.public_timestamp, edition.change_note) }
  end

  def first_public_edition
    document.historic_editions.last
  end

  def first_published_at
    first_public_edition.first_published_at
  end

  def first_public_edition_note
    first_public_edition.change_note.blank? ? 'First published.' : first_public_edition.change_note
  end

  def subsequent_major_editions
    (document.historic_editions - [first_public_edition]).reject(&:minor_change?)
  end
end
