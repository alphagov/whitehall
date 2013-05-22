module Edition::RelatedPolicies
  extend ActiveSupport::Concern

  include Edition::RelatedDocuments

  included do
    has_many :related_policies,
      through: :related_documents,
      source: :latest_edition,
      class_name: 'Policy'
    has_many :published_related_policies, through: :related_documents, source: :published_edition, class_name: 'Policy'
    has_many :topics, through: :published_related_policies, uniq: true

    # Ensure that when we set policy ids we don't remove other types of edition from the array
    define_method(:related_policy_ids=) do |policy_ids|
      policy_ids = [policy_ids].flatten.reject(&:blank?)
      new_policies = policy_ids.map {|id| Policy.find(id).document }
      other_related_documents = self.related_documents.reject { |document| document.latest_edition.is_a?(Policy) }

      self.related_documents = other_related_documents + new_policies
    end
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

  def search_index
    super.merge("topics" => topics.map(&:slug)) {|k, ov, nv| ov + nv}
  end
end
