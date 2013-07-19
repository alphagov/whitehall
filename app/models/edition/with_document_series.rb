module Edition::WithDocumentSeries
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.document_series = @edition.document_series
    end
  end

  included do
    has_many :edition_document_series, foreign_key: :edition_id
    has_many :document_series, through: :edition_document_series

    add_trait Trait
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
