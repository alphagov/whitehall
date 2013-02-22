class WorldwidePriority < Edition
  include Edition::Images
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations

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
