class EditionableWorldwideOrganisation < Edition
  PRIMARY_ROLES = [AmbassadorRole, HighCommissionerRole, GovernorRole].freeze
  SECONDARY_ROLES = [DeputyHeadOfMissionRole].freeze
  OFFICE_ROLES = [WorldwideOfficeStaffRole].freeze

  include Edition::SocialMediaAccounts
  include Edition::Organisations
  include Edition::Roles
  include Edition::WorldLocations

  has_many :offices, class_name: "WorldwideOffice", foreign_key: :edition_id, dependent: :destroy
  belongs_to :main_office, class_name: "WorldwideOffice"

  include AnalyticsIdentifierPopulator
  self.analytics_prefix = "WO"

  def base_path
    "/editionable-world/organisations/#{slug}"
  end

  def display_type_key
    "editionable_worldwide_organisation"
  end

  alias_method :original_main_office, :main_office

  extend HomePageList::Container
  has_home_page_list_of :offices
  def home_page_offices
    super - [main_office]
  end

  def office_shown_on_home_page?(office)
    super || is_main_office?(office)
  end

  def main_office
    original_main_office || offices.first
  end

  def other_offices
    offices - [main_office]
  end

  def is_main_office?(office)
    main_office == office
  end

  def embassy_offices
    offices.select(&:embassy_office?)
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

  def translatable?
    true
  end
end
