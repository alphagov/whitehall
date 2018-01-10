class DocumentHistory
  include Enumerable

  Change = Struct.new(:public_timestamp, :note)

  attr_reader :document, :changes

  delegate :first, :last, :length, :size, :[], :empty?, to: :changes

  def initialize(document, default_first_published_note = 'First published.')
    @default_first_published_note = default_first_published_note
    @document = document

    @changes = if first_public_edition.present?
                 document_changes
               else
                 []
               end
  end

  def each
    changes.each do |change|
      yield(change)
    end
  end

  def newly_published?
    changes.size == 1
  end

  def most_recent_change
    changes.first.public_timestamp
  end

private

  def document_changes
    @document_changes ||= subsequent_changes + [first_change]
  end

  def first_change
    Change.new(first_published_at, first_public_edition_note)
  end

  def subsequent_changes
    subsequent_major_editions.map { |edition| Change.new(edition.public_timestamp, edition.change_note) }
  end

  def first_public_edition
    all_published_editions_in_creation_order.first
  end

  def latest_public_edition
    all_published_editions_in_creation_order.last
  end

  def first_published_at
    all_published_editions_in_creation_order.last.first_public_at
  end

  def first_public_edition_note
    first_public_edition.change_note.presence || @default_first_published_note
  end

  def subsequent_major_editions
    (all_published_editions_in_creation_order.reverse - [first_public_edition]).reject(&:minor_change?)
  end

  def all_published_editions_in_creation_order
    document.ever_published_editions.order('created_at')
  end
end
