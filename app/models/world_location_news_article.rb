class WorldLocationNewsArticle < Newsesque
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations

  def can_be_related_to_policies?
    false
  end

  def can_be_related_to_organisations?
    false
  end

  def skip_organisation_validation?
    true
  end

  def skip_world_location_validation?
    false
  end

  def skip_worldwide_organisations_validation?
    false
  end

  def locale_can_be_changed?
    new_record?
  end

  def search_format_types
    super + [WorldLocationNewsArticle.search_format_type]
  end

  def display_type_key
    'news_article'
  end
end
