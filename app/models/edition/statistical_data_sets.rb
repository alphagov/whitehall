module Edition::StatisticalDataSets
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.statistical_data_set_documents = @edition.statistical_data_set_documents
    end
  end

  included do
    has_many :edition_statistical_data_sets, foreign_key: :edition_id, dependent: :destroy
    has_many :statistical_data_set_documents, through: :edition_statistical_data_sets, source: :document
    has_many :statistical_data_sets, through: :statistical_data_set_documents, source: :latest_edition
    has_many :published_statistical_data_sets, through: :statistical_data_set_documents, source: :published_edition, class_name: 'StatisticalDataSet'


    add_trait Trait
  end

  def statistical_data_sets=(data_sets)
    self.statistical_data_set_documents = data_sets.map(&:document)
  end

  def can_be_associated_with_statistical_data_sets?
    true
  end
end
