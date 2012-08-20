module Edition::DocumentSeries
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.document_series = @edition.document_series
    end
  end

  included do
    belongs_to :document_series

    add_trait Trait
  end

  def can_be_grouped_in_series?
    true
  end
end
