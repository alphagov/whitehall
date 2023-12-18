class EditionableWorldwideOrganisation < Edition
  include Edition::Organisations
  # TODO: These world locations must be `active`, but the one's associated with non-editionable WW Orgs don't. Is that okay?
  include Edition::WorldLocations

  has_many :social_media_accounts, as: :socialable, dependent: :destroy

  def display_type_key
    "editionable_worldwide_organisation"
  end

  def skip_world_location_validation?
    false
  end
end
