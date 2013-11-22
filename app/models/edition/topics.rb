module Edition::Topics
  extend ActiveSupport::Concern
  include Edition::Classifications

  included do
    has_many :topics, through: :classification_memberships, source: :topic
    has_one :topic_suggestion, foreign_key: :edition_id

    accepts_nested_attributes_for :topic_suggestion, allow_destroy: true, reject_if: ->(attrs) {
      attrs[:id].blank? && attrs[:name].blank?
    }

    validate :validate_presence_of_topic, unless: :imported?

    before_validation :mark_topic_suggestion_for_destruction
  end

  def can_be_associated_with_topics?
    true
  end

  def search_index
    super.merge("topics" => topics.map(&:slug)) { |_, ov, nv| ov + nv }
  end

  module ClassMethods
    def in_topic(topic)
      joins(:classification_memberships).where("classification_memberships.classification_id" => topic)
    end

    def published_in_topic(topic)
      published.in_topic(topic)
    end

    def scheduled_in_topic(topic)
      scheduled.in_topic(topic)
    end
  end

private
  def validate_presence_of_topic
    unless has_associated_topics? || has_topic_suggestion?
      errors.add(:topics, "at least one required")
    end
  end

  def has_associated_topics?
    # We need to check the join model because topics will be empty until the
    # classification memberships records are saved, which won't happen until
    # the parent topic is valid. We need to use #empty? here as ActiveRecord
    # overrides it to avoid caching the topics association.
    !(classification_memberships.empty? && topics.empty?)
  end

  def has_topic_suggestion?
    topic_suggestion.present? && !topic_suggestion.marked_for_destruction?
  end

  def mark_topic_suggestion_for_destruction
    if topic_suggestion.present? && topic_suggestion.name.blank?
      topic_suggestion.mark_for_destruction
    end
  end
end
