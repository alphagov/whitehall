class EditionableWorldwideOrganisation < Edition
  include Edition::SocialMediaAccounts
  include Edition::Organisations
  include Edition::Roles
  include Edition::WorldLocations

  def display_type_key
    "editionable_worldwide_organisation"
  end

  def publishing_api_presenter
    PublishingApi::EditionableWorldwideOrganisationPresenter
  end

  def base_path
    "/editionable-world/organisations/#{slug}"
  end

  def skip_world_location_validation?
    false
  end
end
