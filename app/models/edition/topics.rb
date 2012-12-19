module Edition::Topics
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.classification_memberships = @edition.classification_memberships.map do |dt|
        ClassificationMembership.new(dt.attributes.except(:id))
      end
    end
  end

  included do
    has_many :classification_memberships, dependent: :destroy, foreign_key: :edition_id
    has_many :topics, through: :classification_memberships, source: :classification
    after_update :update_topic_counts

    add_trait Trait
  end

  def can_be_associated_with_topics?
    true
  end

  def update_topic_counts
    topics.each(&:update_counts)
    true
  end

  module ClassMethods
    def in_topic(topic)
      joins(:topics).where('classifications.id' => topic)
    end

    def published_in_topic(topic)
      published.in_topic(topic)
    end

    def scheduled_in_topic(topic)
      scheduled.in_topic(topic)
    end
  end
end
