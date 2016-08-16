# DID YOU MEAN: Topic?
# "Policy area" is the newer name for "topic"
# (https://www.gov.uk/government/topics)
# "Topic" is the newer name for "specialist sector"
# (https://www.gov.uk/topic)
class SpecialistSector < ActiveRecord::Base
  belongs_to :edition

  validates :edition, presence: true
  validates :tag, presence: true, uniqueness: { scope: :edition_id }

  def self.grouped_sector_topics
    nested_sectors.map do |sector_tag, topic_tags|
      sector_topic_from_tag(sector_tag, topic_tags.map { |tag| sector_topic_from_tag(tag) })
    end
  end

  def edition
    Edition.unscoped { super }
  end

private
  def self.nested_sectors
    find_subsectors(fetch_sectors).group_by(&:parent).sort_by {|parent, _| parent.title }
  end

  def self.find_subsectors(sectors)
    sectors.select(&:parent)
  end

  # DID YOU MEAN: Topic?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  def self.fetch_sectors
    Whitehall.content_api.tags('specialist_sector', draft: true)
  rescue
    raise DataUnavailable.new
  end

  def self.sector_topic_from_tag(tag, topics = [])
    OpenStruct.new(slug: slug_for_sector_tag(tag), title: tag.title, topics: topics, draft?: (tag.state == 'draft'))
  end

  def self.slug_for_sector_tag(tag)
    Addressable::URI.unescape(tag.id.match(%r{/([^/]*)\.json})[1])
  end

  class DataUnavailable < StandardError; end
end
