module Document::RelatedPolicies
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      document.related_document_identities = @document.related_document_identities
    end
  end

  included do
    has_many :document_relations, foreign_key: :document_id
    has_many :related_document_identities, through: :document_relations, source: :document_identity
    has_many :related_policies, through: :related_document_identities, source: :latest_edition
    has_many :published_related_policies, through: :related_document_identities, source: :published_document, class_name: 'Policy'

    define_method(:related_policies=) do |policies|
      self.related_document_identities = policies.map(&:document_identity)
    end

    add_trait Trait
  end

  def can_be_related_to_policies?
    true
  end
end
