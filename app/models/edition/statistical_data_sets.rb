module Edition::StatisticalDataSets
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.statistical_data_sets = @edition.statistical_data_sets
    end
  end

  included do
    has_many :edition_statistical_data_sets, foreign_key: :edition_id, dependent: :destroy
    has_many :statistical_data_sets, through: :edition_statistical_data_sets

    add_trait Trait
  end

  def can_be_associated_with_statistical_data_sets?
    true
  end
end
