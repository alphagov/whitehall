class WorldwidePriority < Edition
  include Edition::Images
  include Edition::Organisations
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations

  has_many :edition_relations, through: :document
  has_many :related_editions, through: :edition_relations, source: :edition
  has_many :published_related_editions,
    through: :edition_relations,
    conditions: { editions: { state: "published" } },
    source: :edition
  has_many :published_related_world_location_news,
    through: :edition_relations,
    conditions: { editions: { type: WorldLocationNewsArticle.sti_names, state: "published" } },
    source: :edition
  has_many :published_case_studies,
    through: :edition_relations,
    conditions: { editions: { type: "CaseStudy", state: "published" } },
    source: :edition

  def display_type_key
    "worldwide_priority"
  end

  def search_format_types
    super + [WorldwidePriority.search_format_type]
  end

  def presenter
    WorldwidePriorityPresenter
  end

  def translatable?
    !non_english_edition?
  end
end
