# A bunch of helpers for efficiently generating select options for taggable
# content, e.g. topics, organisations, etc.
module Admin::TaggableContentHelper

  # Returns an Array that represents the current set of taggable topics.
  # Each element of the array consists of two value: the name and ID of the
  # topic.
  def taggable_topics_container
    Rails.cache.fetch(taggable_topics_cache_digest) do
      Topic.order(:name).map { |t| [t.name, t.id] }
    end
  end

  # Returns an Array that represents the current set of taggable topical
  # events. Each element of the array consists of two values: the name and ID
  # of the topical event.
  def taggable_topical_events_container
    Rails.cache.fetch(taggable_topical_events_cache_digest) do
      TopicalEvent.order(:name).map { |te| [te.name, te.id] }
    end
  end

  # Returns an Array that represents the current set of taggable organisations.
  # Each element of the the array consists of two values: the select_name and
  # the ID of the organisation
  def taggable_organisations_container
    Rails.cache.fetch(taggable_organisations_cache_digest) do
      Organisation.with_translations.order(:name).map { |o| [o.select_name, o.id] }
    end
  end

  # Returns an MD5 digest representing the current set of taggable topics. This
  # will change if any of the Topics should change or if a new topic is added.
  def taggable_topics_cache_digest
    update_timestamps = Topic.order(:id).pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-topics-#{update_timestamps}"
  end

  # Returns an MD5 digest representing the current set of taggable topical
  # events. This will change if any of the Topics should change or if a new
  # topic is added.
  def taggable_topical_events_cache_digest
    update_timestamps = TopicalEvent.order(:id).pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-topical-events-#{update_timestamps}"
  end

  def taggable_organisations_cache_digest
    @taggable_organisations_cache_digest ||= begin
      update_timestamps = Organisation.order(:id).pluck(:updated_at).map(&:to_i).join
      Digest::MD5.hexdigest "taggable-organisations-#{update_timestamps}"
    end
  end

  # Note: Taken from Rails 4
  def cache_if(condition, name = {}, options = nil, &block)
    if condition
      cache(name, options, &block)
    else
      yield
    end

    nil
  end
end
