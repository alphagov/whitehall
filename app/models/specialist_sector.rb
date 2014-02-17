class SpecialistSector < ActiveRecord::Base
  belongs_to :edition

  validates :edition, presence: true
  validates :tag, presence: true, uniqueness: { scope: :edition_id }

  def self.grouped_sector_topics
    nested_sectors.map do |sector_tag, topic_tags|
      OpenStruct.new(
        slug: slug_for_sector_tag(sector_tag),
        title: sector_tag.title,
        topics: topic_tags.map { |tag| sector_topic_from_tag(tag) }
      )
    end
  end

private
  def self.nested_sectors
    fetch_sectors.select(&:parent).group_by(&:parent)
  end

  def self.fetch_sectors
    Whitehall.content_api.tags('specialist_sectors')
  rescue
    raise DataUnavailable.new
  end

  def self.sector_topic_from_tag(tag)
    OpenStruct.new(slug: slug_for_sector_tag(tag), title: tag.title)
  end

  def self.slug_for_sector_tag(tag)
    URI.unescape(tag.id.match(%r{/([^/]*)\.json})[1])
  end

  class DataUnavailable < StandardError; end
end
