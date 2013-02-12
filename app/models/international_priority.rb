class InternationalPriority < Edition
  include Edition::Images
  include Edition::WorldLocations
  include Edition::WorldwideOffices

  def display_type_key
    "international_priority"
  end

  def search_format_types
    super + ['international-priority']
  end
end
