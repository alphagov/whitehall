module Edition::HasDocumentSeries
  extend ActiveSupport::Concern

  included do
    has_many :document_series, through: :document
  end

  def can_be_grouped_in_series?
    true
  end

  def part_of_series?
    document_series.any?
  end

  def search_index
    super.merge("document_series" => document_series.map(&:slug))
  end

  # We allow document series to be assigned directly on an edition for speed tagging
  def document_series_ids=(ids)
    if new_record?
      raise(StandardError, 'cannot assign document series to an unsaved edition')
    end
    document.document_series_ids = ids
  end
end
