class WorldwideOrganisation < ActiveRecord::Base
  PRIMARY_ROLES = [AmbassadorRole, HighCommissionerRole, GovernorRole]

  has_many :worldwide_organisation_world_locations, dependent: :destroy
  has_many :world_locations, through: :worldwide_organisation_world_locations
  has_many :social_media_accounts, as: :socialable, dependent: :destroy
  has_many :sponsorships, dependent: :destroy
  has_many :sponsoring_organisations, through: :sponsorships, source: :organisation
  has_many :offices, class_name: 'WorldwideOffice', dependent: :destroy
  belongs_to :main_office, class_name: 'WorldwideOffice'
  has_many :worldwide_organisation_roles, dependent: :destroy
  has_many :roles, through: :worldwide_organisation_roles
  has_many :people, through: :roles
  has_many :corporate_information_pages, as: :organisation, dependent: :destroy, through: :corporate_information_pages_organisations
  has_one  :access_and_opening_times, as: :accessible, dependent: :destroy
  belongs_to :default_news_image, class_name: 'DefaultNewsOrganisationImageData', foreign_key: :default_news_organisation_image_data_id

  accepts_nested_attributes_for :default_news_image, reject_if: :all_blank

  scope :ordered_by_name, ->() { with_translations(I18n.default_locale).order(translation_class.arel_table[:name]) }

  include AnalyticsIdentifierPopulator
  self.analytics_prefix = 'WO'

  include TranslatableModel
  translates :name, :summary, :description, :services

  alias_method :original_main_office, :main_office

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attributes: [:description, :services]
  validates :name, :summary, :description, presence: true

  extend FriendlyId
  friendly_id

  # I'm trying to use a domain centric design rather than a persistence
  # centric design, so I do not want to expose a has_many :home_page_lists
  # and all that this implies. I really only want to expose a list of
  # contacts (in order) that should be shown on the home page, and some
  # simple (explicit) methods for manipulating them.
  extend HomePageList::Container
  has_home_page_list_of :offices
  def home_page_offices
    super - [main_office]
  end
  def office_shown_on_home_page?(office)
    super || is_main_office?(office)
  end

  delegate :alternative_format_contact_email, to: :sponsoring_organisation, allow_nil: true
  def sponsoring_organisation
    sponsoring_organisations.first
  end

  include Searchable
  searchable title: :name,
             link: :search_link,
             content: :summary,
             format: 'worldwide_organisation'

  def search_link
    Whitehall.url_maker.worldwide_organisation_path(slug)
  end

  def display_name
    self.name
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

  def primary_role
    roles.where(type: PRIMARY_ROLES.map(&:name)).first
  end

  def secondary_role
    roles.where(type: DeputyHeadOfMissionRole.name).first
  end

  def office_staff_roles
    roles.where(type: WorldwideOfficeStaffRole.name)
  end

  def unused_corporate_information_page_types
    CorporateInformationPageType.all - corporate_information_pages.map(&:type)
  end
end
