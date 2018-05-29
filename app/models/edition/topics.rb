# DID YOU MEAN: Policy Area?
# "Policy area" is the newer name for "topic"
# (https://www.gov.uk/government/topics)
# "Topic" is the newer name for "specialist sector"
# (https://www.gov.uk/topic)
# You can help improve this code by renaming all usages of this field to use
# the new terminology.
module Edition::Topics
  extend ActiveSupport::Concern
  include Edition::Classifications

  included do
    has_many :topics, through: :classification_memberships, source: :topic
  end

  def can_be_associated_with_topics?
    true
  end

  def has_policy_areas?
    topics.any?
  end

  def search_index
    # "Policy area" is the newer name for "topic"
    # (https://www.gov.uk/government/topics)
    # Rummager's policy areas also include "topical events", which we model
    # separately in whitehall.
    new_slugs = topics.map(&:slug)
    existing_slugs = super.fetch("policy_areas", [])
    super.merge("policy_areas" => new_slugs + existing_slugs)
  end

  def title_with_topics
    "#{title} (#{topics.map(&:name).to_sentence})"
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

  def has_at_least_one_topic
    # We need to check the join model because topics will be empty until the
    # classification memberships records are saved, which won't happen until
    # the parent topic is valid. We need to use #empty? here as ActiveRecord
    # overrides it to avoid caching the topics association.
    if classification_memberships.empty? && topics.empty?
      errors.add(:policy_area, "at least one required")
    end
  end
end
