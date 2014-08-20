module Admin::TaggableContentHelper

  # Returns an Array that represents the current set of taggable topics.
  # Each element of the array consists of two values: the first is the
  # topic name; the second the topic ID.
  def taggable_topics_container
    Rails.cache.fetch(taggable_topics_cache_digest) do
      Topic.order(:name).map { |t| [t.name, t.id] }
    end
  end

  # Returns an MD5 digest representing the current set of taggable topics. This
  # will change if any of the Topics should change or if a new topic is added.
  def taggable_topics_cache_digest
    update_timestamps = Topic.pluck(:updated_at).map(&:to_i).join
    Digest::MD5.hexdigest "taggable-topics-#{update_timestamps}"
  end
end
