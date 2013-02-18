class WorldLocationNewsArticle < Newsesque
  include Edition::WorldwidePriorities
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations

  def can_be_related_to_policies?
    false
  end
end
