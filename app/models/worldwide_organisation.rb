class WorldwideOrganisation < ApplicationRecord
  PRIMARY_ROLES = [AmbassadorRole, HighCommissionerRole, GovernorRole].freeze
  SECONDARY_ROLES = [DeputyHeadOfMissionRole].freeze
  OFFICE_ROLES = [WorldwideOfficeStaffRole].freeze

  has_many :worldwide_organisation_world_locations, dependent: :destroy
  has_many :world_locations, through: :worldwide_organisation_world_locations
  has_many :social_media_accounts, as: :socialable, dependent: :destroy
  has_many :sponsorships, dependent: :destroy
  has_many :sponsoring_organisations, through: :sponsorships, source: :organisation
  has_many :offices, class_name: "WorldwideOffice", dependent: :destroy
  belongs_to :main_office, class_name: "WorldwideOffice"
  has_many :worldwide_organisation_roles, inverse_of: :worldwide_organisation, dependent: :destroy
  has_many :roles, through: :worldwide_organisation_roles
  has_many :people, through: :roles
  has_many :edition_worldwide_organisations, dependent: :destroy, inverse_of: :worldwide_organisation
  # This include is dependant on the above has_many
  include HasCorporateInformationPages

  has_many :editions, through: :edition_worldwide_organisations

  has_one :default_news_image, class_name: "FeaturedImageData", as: :featured_imageable, inverse_of: :featured_imageable

  accepts_nested_attributes_for :default_news_image, reject_if: :all_blank

  scope :ordered_by_name, -> { with_translations(I18n.default_locale).order(translation_class.arel_table[:name]) }

  include AnalyticsIdentifierPopulator
  self.analytics_prefix = "WO"

  include TranslatableModel
  translates :name

  alias_method :original_main_office, :main_office
  alias_method :title, :name

  validates_with SafeHtmlValidator
  validates :name, presence: true

  include PublishesToPublishingApi

  include AuditTrail

  extend FriendlyId
  friendly_id

  after_commit :republish_embassies_index_page_to_publishing_api, :republish_worldwide_offices

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

  def home_page_office_contacts
    home_page_offices&.map(&:contact)
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
             link: :public_path,
             content: :summary,
             format: "worldwide_organisation"

  def display_name
    name
  end

  def acronym
    nil
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

  def primary_role
    roles.occupied.find_by(type: PRIMARY_ROLES.map(&:name))
  end

  def secondary_role
    roles.occupied.find_by(type: SECONDARY_ROLES.map(&:name))
  end

  def office_staff_roles
    roles.occupied.where(type: OFFICE_ROLES.map(&:name))
  end

  def base_path
    "/world/organisations/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  def republish_embassies_index_page_to_publishing_api
    PresentPageToPublishingApiWorker.perform_async("PublishingApi::EmbassiesIndexPresenter")
  end

  def republish_worldwide_offices
    return if offices.blank?

    offices.each { |office| Whitehall::PublishingApi.republish_async(office) }
  end

  def search_index
    super.merge("world_locations" => world_locations.map(&:slug))
  end

  def publishing_api_presenter
    PublishingApi::WorldwideOrganisationPresenter
  end

  def republish_dependent_documents
    documents = NewsArticle
                  .in_worldwide_organisation(self)
                  .includes(:images)
                  .where(images: { id: nil })
                  .map(&:document)
                  .uniq(&:id)
    documents.each { |d| Whitehall::PublishingApi.republish_document_async(d) }
  end
end
