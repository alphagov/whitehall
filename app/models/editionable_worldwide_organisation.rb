class EditionableWorldwideOrganisation < Edition
  PRIMARY_ROLES = [AmbassadorRole, HighCommissionerRole, GovernorRole].freeze
  SECONDARY_ROLES = [DeputyHeadOfMissionRole].freeze
  OFFICE_ROLES = [WorldwideOfficeStaffRole].freeze

  include Edition::SocialMediaAccounts
  include Edition::Organisations
  include Edition::Roles
  include Edition::WorldLocations

  has_many :offices, class_name: "WorldwideOffice", foreign_key: :edition_id, dependent: :destroy, autosave: true
  belongs_to :main_office, class_name: "WorldwideOffice"

  class CloneOfficesTrait < Edition::Traits::Trait
    def process_associations_before_save(new_edition)
      @edition.offices.each do |office|
        new_office = new_edition.offices.build(office.attributes.except("id", "edition_id"))

        new_office.contact = office.contact.dup
      end
    end
  end

  add_trait CloneOfficesTrait

  include AnalyticsIdentifierPopulator
  self.analytics_prefix = "WO"

  def base_path
    "/editionable-world/organisations/#{slug}"
  end

  def display_type_key
    "editionable_worldwide_organisation"
  end

  def self.format_name
    "worldwide organisation"
  end

  def multipart_content_paths
    ([main_office] + home_page_offices)
      .compact
      .select { |office| office.contact.available_in_locale?(I18n.locale) }
      .map { |office| office.public_path(locale: I18n.locale) }
  end

  alias_method :original_main_office, :main_office

  extend HomePageList::Container
  has_home_page_list_of :offices
  def home_page_offices
    super - [main_office]
  end

  def home_page_office_contacts
    home_page_offices&.map(&:contact)
  end

  def office_shown_on_home_page?(office)
    super || is_main_office?(office)
  end

  def main_office
    original_main_office || offices.first
  end

  def main_office_contact
    main_office&.contact
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

  def previously_published
    false
  end

  def can_have_supporting_organisations?
    false
  end

  def can_set_previously_published?
    false
  end

  def can_be_marked_political?
    false
  end

  def skip_world_location_validation?
    false
  end

  def summary_required?
    false
  end

  def translatable?
    true
  end

  def requires_taxon?
    false
  end
end
