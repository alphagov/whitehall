class DocumentHistory
  include Enumerable

  class Change < Struct.new(:public_timestamp, :note)
  end

  attr_reader :document, :changes

  delegate :first, :last, :length, :size, :[], :empty?, to: :changes

  def initialize(document, default_first_published_note = 'First published.')
    @default_first_published_note = default_first_published_note
    @document = document

    if first_public_edition.present?
      @changes = (document_changes + unique_supporting_pages_changes).sort_by {|c| -c.public_timestamp.to_i }
    else
      @changes = []
    end
  end

  def each(&block)
    changes.each do |change|
      block.call(change)
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
    all_published_editions.last
  end

  def latest_public_edition
    all_published_editions.first
  end

  def first_published_at
    first_public_edition.first_published_at
  end

  def first_public_edition_note
    first_public_edition.change_note.presence || @default_first_published_note
  end

  def subsequent_major_editions
    (all_published_editions - [first_public_edition]).reject(&:minor_change?)
  end

  def all_published_editions
    document.ever_published_editions.in_reverse_chronological_order
  end

  def supporting_pages
    latest_public_edition.respond_to?(:published_supporting_pages) ? latest_public_edition.published_supporting_pages : []
  end

  def supporting_pages_changes
    supporting_pages.flat_map do |supporting_page|
      DocumentHistory.new(supporting_page.document, "Detail added: #{supporting_page.title}").changes
    end
  end

  def unique_supporting_pages_changes
    supporting_pages_changes.reject do |sub_change|
      document_changes.any? { |main_change| main_change.public_timestamp.to_i == sub_change.public_timestamp.to_i }
    end
  end
end
