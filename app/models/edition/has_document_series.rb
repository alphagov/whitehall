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
end
