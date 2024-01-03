class EditionableWorldwideOrganisation < Edition
  PRIMARY_ROLES = [AmbassadorRole, HighCommissionerRole, GovernorRole].freeze
  SECONDARY_ROLES = [DeputyHeadOfMissionRole].freeze
  OFFICE_ROLES = [WorldwideOfficeStaffRole].freeze

  include Edition::SocialMediaAccounts
  include Edition::Organisations
  include Edition::Roles
  include Edition::WorldLocations

  def base_path
    "/editionable-world/organisations/#{slug}"
  end

  def display_type_key
    "editionable_worldwide_organisation"
  end

  def office_staff_roles
    roles.occupied.where(type: OFFICE_ROLES.map(&:name))
  end

  def primary_role
    roles.occupied.find_by(type: PRIMARY_ROLES.map(&:name))
  end

  def publishing_api_presenter
    PublishingApi::EditionableWorldwideOrganisationPresenter
  end

  def secondary_role
    roles.occupied.find_by(type: SECONDARY_ROLES.map(&:name))
  end

  def skip_world_location_validation?
    false
  end
end
