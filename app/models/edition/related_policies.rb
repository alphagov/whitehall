module Edition::RelatedPolicies
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      edition.related_documents = @edition.related_documents
    end
  end

  included do
    has_many :edition_relations, foreign_key: :edition_id, dependent: :destroy
    has_many :related_documents, through: :edition_relations, source: :document
    has_many :related_policies, through: :related_documents, source: :latest_edition
    has_many :published_related_policies, through: :related_documents, source: :published_edition, class_name: 'Policy'
    has_many :topics, through: :published_related_policies, uniq: true

    define_method(:related_policies=) do |policies|
      self.related_documents = policies.map(&:document)
    end

    add_trait Trait
  end

  def can_be_related_to_policies?
    true
  end

  module ClassMethods
    def in_topic(topics)
      topic_ids = topics.map do |topic|
        topic.respond_to?(:id) ? topic.id.to_i : topic.to_i
      end
      where("
        EXISTS (
          SELECT 1
          FROM edition_relations er
            JOIN editions policy ON
              er.document_id = policy.document_id AND
              policy.state = 'published' AND
              NOT EXISTS (
                SELECT 1 FROM editions e3
                WHERE
                  e3.document_id = policy.document_id
                  AND e3.id > policy.id AND e3.state = 'published'
              )
            JOIN classification_memberships cm ON cm.edition_id = policy.id
          WHERE
            er.edition_id = editions.id
            AND cm.classification_id in (?)
        )
      ", topic_ids)
    end

    def published_in_topic(topics)
      latest_published_edition.in_topic(topics)
    end

    def scheduled_in_topic(topics)
      scheduled.in_topic(topics)
    end
  end

  module InstanceMethods
    def search_index
      super.merge("topics" => topics.map(&:id))
    end
  end
end
