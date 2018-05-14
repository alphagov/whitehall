class WorldwideOrganisation < ApplicationRecord
  PRIMARY_ROLES = [AmbassadorRole, HighCommissionerRole, GovernorRole].freeze
  SECONDARY_ROLES = [DeputyHeadOfMissionRole].freeze
  OFFICE_ROLES = [WorldwideOfficeStaffRole].freeze

  has_many :worldwide_organisation_world_locations, dependent: :destroy
  has_many :world_locations, through: :worldwide_organisation_world_locations
  has_many :social_media_accounts, as: :socialable, dependent: :destroy
  has_many :sponsorships, dependent: :destroy
  has_many :sponsoring_organisations, through: :sponsorships, source: :organisation
  has_many :offices, class_name: 'WorldwideOffice', dependent: :destroy
  belongs_to :main_office, class_name: 'WorldwideOffice'
  has_many :worldwide_organisation_roles, inverse_of: :worldwide_organisation, dependent: :destroy
  has_many :roles, through: :worldwide_organisation_roles
  has_many :people, through: :roles
  has_many :edition_worldwide_organisations, dependent: :destroy, inverse_of: :worldwide_organisation
  # This include is dependant on the above has_many
  include HasCorporateInformationPages
  has_one  :access_and_opening_times, as: :accessible, dependent: :destroy
  belongs_to :default_news_image, class_name: 'DefaultNewsOrganisationImageData', foreign_key: :default_news_organisation_image_data_id

  accepts_nested_attributes_for :default_news_image, reject_if: :all_blank

  scope :ordered_by_name, ->() { with_translations(I18n.default_locale).order(translation_class.arel_table[:name]) }

  include AnalyticsIdentifierPopulator
  self.analytics_prefix = 'WO'

  include TranslatableModel
  translates :name

  alias_method :original_main_office, :main_office

  validates_with SafeHtmlValidator
  validates :name, presence: true

  include PublishesToPublishingApi

  extend FriendlyId
  friendly_id

  after_save do
    # If the default news organisation image changes we need to republish all
    # news articles belonging to the worldwide organisation
    if default_news_organisation_image_data_id_changed?
      documents = NewsArticle
        .in_worldwide_organisation(self)
        .includes(:images)
        .where(images: { id: nil })
        .map(&:document)

      documents.each { |d| Whitehall::PublishingApi.republish_document_async(d) }
    end
  end

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
             description: :summary,
             link: :search_link,
             content: :summary,
             format: 'worldwide_organisation'

  def search_link
    Whitehall.url_maker.worldwide_organisation_path(slug)
  end

  def display_name
    self.name
  end

  def acronym
    nil
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
    roles.occupied.where(type: PRIMARY_ROLES.map(&:name)).first
  end

  def secondary_role
    roles.occupied.where(type: SECONDARY_ROLES.map(&:name)).first
  end

  def office_staff_roles
    roles.occupied.where(type: OFFICE_ROLES.map(&:name))
  end
end
