module Edition::RelatedPolicies
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.related_doc_identities = @edition.related_doc_identities
    end
  end

  included do
    has_many :edition_relations, foreign_key: :edition_id, dependent: :destroy
    has_many :related_doc_identities, through: :edition_relations, source: :doc_identity
    has_many :related_policies, through: :related_doc_identities, source: :latest_edition
    has_many :published_related_policies, through: :related_doc_identities, source: :published_edition, class_name: 'Policy'

    define_method(:related_policies=) do |policies|
      self.related_doc_identities = policies.map(&:doc_identity)
    end

    add_trait Trait
  end

  def can_be_related_to_policies?
    true
  end

  module ClassMethods
    def in_policy_topic(policy_topics)
      policy_topic_ids = policy_topics.map do |policy_topic|
        policy_topic.respond_to?(:id) ? policy_topic.id.to_i : policy_topic.to_i
      end
      latest_published_edition.where("
        exists (
          select 1
          from edition_relations dr
            join editions policy on
              dr.doc_identity_id = policy.doc_identity_id and
              policy.state='published' and
              NOT EXISTS (
                SELECT 1 FROM editions e3
                WHERE
                  e3.doc_identity_id = policy.doc_identity_id
                  AND e3.id > policy.id AND e3.state = 'published'
              )
            join policy_topic_memberships ptm on ptm.policy_id = policy.id
          where
            dr.edition_id=editions.id
            and ptm.policy_topic_id in (?)
        )
      ", policy_topic_ids)
    end
  end
end
