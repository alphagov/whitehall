module Document::RelatedPolicies
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      document.related_document_identities = @document.related_document_identities
    end
  end

  included do
    has_many :document_relations, foreign_key: :document_id, dependent: :destroy
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

  module ClassMethods
    def in_policy_topic(policy_topic)
      policy_topic_id = policy_topic.respond_to?(:id) ? policy_topic.id : policy_topic
      latest_published_edition.where("
        exists (
          select 1
          from document_relations dr 
            join documents policy on 
              dr.document_identity_id = policy.document_identity_id and 
              policy.state='published' and
              NOT EXISTS (
                SELECT 1 FROM documents d3 
                WHERE 
                  d3.document_identity_id = policy.document_identity_id 
                  AND d3.id > policy.id AND d3.state = 'published'
              ) 
            join policy_topic_memberships ptm on ptm.policy_id = policy.id
          where 
            dr.document_id=documents.id
            and ptm.policy_topic_id=%d
        )
      ", policy_topic_id)
    end
  end
end
