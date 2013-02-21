class WorldLocationNewsArticle < Newsesque
  include Edition::WorldwidePriorities
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations

  def can_be_related_to_policies?
    false
  end

  def display_type_key
    'world_location_news_article'
  end
end
