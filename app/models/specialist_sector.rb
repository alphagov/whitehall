class SpecialistSector < ActiveRecord::Base
  belongs_to :edition

  validates :edition, presence: true
  validates :tag, presence: true, uniqueness: { scope: :edition_id }

  def self.options_for_select
    nested_sectors.map do |parent, tags|
      [parent.title, tags.map { |tag| option_for_tag(tag, parent.title) }]
    end
  end

private
  def self.nested_sectors
    fetch_sectors.select(&:parent).group_by(&:parent)
  end

  def self.fetch_sectors
    Whitehall.content_api.tags('specialist_sectors')
  end

  def self.option_for_tag(tag, parent_title)
    label = "#{parent_title}: #{tag.title}"
    slug = URI.unescape(tag.id.match(%r{/([^/]*)\.json})[1])

    [label, slug]
  end
end
