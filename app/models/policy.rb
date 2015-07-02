# A model to represent policies that are published by policy-publisher
# and stored in the content-store.
class Policy
  attr_reader :base_path, :content_id, :title

  def initialize(attributes)
    @base_path = attributes["base_path"]
    @content_id = attributes["content_id"]
    @title = attributes["title"]
    @links = attributes["links"]
  end

  def self.find(content_id)
    if attributes = find_entry(content_id)
      new(attributes)
    end
  end

  def self.all
    entries.map { |attrs| new(attrs) }
  end

  def self.from_content_ids(content_ids)
    content_ids.map { |content_id| find(content_id) }.compact
  end

  def topics
    []
  end

  def slug
    @slug ||= base_path.split('/').last
  end

  def policy_areas
    @policy_areas ||= Policy.from_content_ids(policy_area_content_ids)
  end

  def policy_area_titles
    policy_areas.map(&:title)
  end

private

  attr_reader :links

  def self.entries
    Rails.cache.fetch('policy.entries', expires_in: 5.minutes) do
      content_register.entries("policy").to_a
    end
  end

  def self.find_entry(content_id)
    entries.find { |p| p["content_id"] == content_id }
  end

  def self.content_register
    @content_register ||= Whitehall.content_register
  end

  def policy_area_content_ids
    links.fetch("policy_areas", []).map { |link| link["content_id"] }
  end
end
