class WorldwidePriority < Edition
  include Edition::Images
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations

  has_many :edition_worldwide_priorities, dependent: :destroy
  has_many :related_editions, through: :edition_worldwide_priorities, source: :edition
  has_many :published_related_editions,
    through: :edition_worldwide_priorities,
    conditions: { state: "published" },
    source: :edition
  has_many :published_related_world_location_news,
    through: :edition_worldwide_priorities,
    conditions: { type: WorldLocationNewsArticle.sti_names, state: "published" },
    source: :edition

  def display_type_key
    "worldwide_priority"
  end

  def search_format_types
    super + [WorldwidePriority.search_format_type]
  end

  def translatable?
    true
  end
end
