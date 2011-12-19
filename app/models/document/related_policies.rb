module Document::RelatedPolicies
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      document.related_policies = @document.related_policies
    end
  end

  included do
    has_many :document_relations, foreign_key: :document_id
    has_many :related_policies, through: :document_relations, source: :policy
    has_many :published_related_policies, through: :document_relations, source: :policy, conditions: { "documents.state" => "published" }

    add_trait Trait
  end

  def can_be_related_to_policies?
    true
  end
end
