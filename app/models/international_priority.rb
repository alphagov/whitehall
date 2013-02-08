class InternationalPriority < Edition
  include Edition::Images
  include Edition::WorldLocations

  def display_type_key
    "international_priority"
  end
end
