module Document::PolicyAreas
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_before_save(document)
      document.document_policy_areas = @document.document_policy_areas.map do |dt|
        DocumentPolicyArea.new(dt.attributes.except(:id))
      end
    end
  end

  included do
    has_many :document_policy_areas, foreign_key: :document_id
    has_many :policy_areas, through: :document_policy_areas

    add_trait Trait
  end

  def can_be_associated_with_policy_areas?
    true
  end

  module ClassMethods
    def in_policy_area(policy_area)
      joins(:policy_areas).where('policy_areas.id' => policy_area)
    end
  end
end