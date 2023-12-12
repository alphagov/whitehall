class EditionableWorldwideOrganisation < Edition
  include Edition::Organisations

  def display_type_key
    "editionable_worldwide_organisation"
  end
end
