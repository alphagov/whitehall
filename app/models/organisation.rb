class Organisation < ActiveRecord::Base
  include Searchable
  include Organisation::OrganisationTypeConcern

  belongs_to :default_news_image, class_name: 'DefaultNewsOrganisationImageData', foreign_key: :default_news_organisation_image_data_id

  has_many :child_organisational_relationships,
            foreign_key: :parent_organisation_id,
            class_name: "OrganisationalRelationship"
  has_many :parent_organisational_relationships,
            foreign_key: :child_organisation_id,
            class_name: "OrganisationalRelationship",
            dependent: :destroy
  has_many :child_organisations,
            through: :child_organisational_relationships
  has_many :parent_organisations,
            through: :parent_organisational_relationships

  has_many :edition_organisations, dependent: :destroy
  has_many :editions, through: :edition_organisations

  has_many :organisation_roles
  has_many :roles, through: :organisation_roles
  has_many :groups
  has_many :ministerial_roles,
            class_name: 'MinisterialRole',
            through: :organisation_roles,
            source: :role,
            conditions: "roles.whip_organisation_id IS null"
  has_many :ministerial_whip_roles,
            class_name: 'MinisterialRole',
            through: :organisation_roles,
            source: :role,
            conditions: "roles.whip_organisation_id IS NOT null"
  has_many :management_roles,
            through: :organisation_roles,
            source: :role,
            conditions: "type = 'BoardMemberRole' OR type = 'ChiefScientificAdvisorRole'"
  has_many :military_roles,
            class_name: 'MilitaryRole',
            through: :organisation_roles,
            source: :role
  has_many :traffic_commissioner_roles,
            class_name: 'TrafficCommissionerRole',
            through: :organisation_roles,
            source: :role
  has_many :chief_professional_officer_roles,
            class_name: 'ChiefProfessionalOfficerRole',
            through: :organisation_roles,
            source: :role
  has_many :special_representative_roles,
            class_name: 'SpecialRepresentativeRole',
            through: :organisation_roles,
            source: :role
  has_many :ministerial_role_appointments,
            class_name: 'RoleAppointment',
            through: :ministerial_roles,
            source: :role_appointments
  has_many :ministerial_whip_role_appointments,
            class_name: 'RoleAppointment',
            through: :ministerial_whip_roles,
            source: :role_appointments

  has_many :people, through: :roles

  has_many :organisation_classifications, dependent: :destroy, order: 'organisation_classifications.ordering'
  has_many :topics, through: :organisation_classifications, order: 'organisation_classifications.ordering'
  has_many :classifications, through: :organisation_classifications

  has_many :organisation_mainstream_categories, dependent: :destroy, order: 'organisation_mainstream_categories.ordering', inverse_of: :organisation
  has_many :mainstream_categories, through: :organisation_mainstream_categories, order: 'organisation_mainstream_categories.ordering'

  has_many :users, foreign_key: :organisation_slug, primary_key: :slug, dependent: :nullify

  has_many :corporate_information_pages, dependent: :destroy, through: :edition_organisations, source: :edition, class_name: "CorporateInformationPage"

  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :social_media_accounts, as: :socialable, dependent: :destroy, include: [:social_media_service]

  has_many :sponsorships, dependent: :destroy
  has_many :sponsored_worldwide_organisations, through: :sponsorships, source: :worldwide_organisation

  has_many :financial_reports

  has_and_belongs_to_many :superseding_organisations, class_name: "Organisation", foreign_key: :superseded_organisation_id, join_table: :organisation_supersedings, association_foreign_key: :superseding_organisation_id
  has_and_belongs_to_many :superseded_organisations, class_name: "Organisation", foreign_key: :superseding_organisation_id, join_table: :organisation_supersedings, association_foreign_key: :superseded_organisation_id

  has_one :featured_topics_and_policies_list
  def featured_topics_and_policies_list_summary
    featured_topics_and_policies_list.try(:summary)
  end

  # I'm trying to use a domain centric design rather than a persistence
  # centric design, so I do not want to expose a has_many :home_page_lists
  # and all that this implies. I really only want to expose a list of
  # contacts (in order) that should be shown on the home page, and some
  # simple (explicit) methods for manipulating them.
  extend HomePageList::Container
  has_home_page_list_of :contacts
  def home_page_contacts
    super.reject(&:foi?)
  end
  def contact_shown_on_home_page?(contact)
    super || (contact.foi? && contact.contactable == self)
  end
  def foi_contacts
    contacts.where(contact_type_id: ContactType::FOI.id)
  end

  has_many :promotional_features

  include HasTopTasks

  accepts_nested_attributes_for :default_news_image, reject_if: :all_blank
  accepts_nested_attributes_for :organisation_roles
  accepts_nested_attributes_for :edition_organisations
  accepts_nested_attributes_for :organisation_classifications, reject_if: -> attributes { attributes['classification_id'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :organisation_mainstream_categories, reject_if: -> attributes { attributes['mainstream_category_id'].blank? }, allow_destroy: true

  validates :slug, presence: true, uniqueness: true
  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attributes: [:description, :about_us]
  validates :name, presence: true, uniqueness: true
  validates :logo_formatted_name, presence: true
  validates :url, uri: true, allow_blank: true
  validates :organisation_chart_url, uri: true, allow_blank: true
  validates :alternative_format_contact_email, email_format: {allow_blank: true}
  validates :alternative_format_contact_email, presence: {
    if: :requires_alternative_format?,
    message: "can't be blank as there are editions which use this organisation as the alternative format provider"}
  validates :govuk_status, inclusion: {in: %w{live joining exempt transitioning closed}}
  validates :organisation_logo_type_id, presence: true
  validates :logo, presence: true, if: :custom_logo_selected?

  delegate :ministerial_department?, to: :type

  include TranslatableModel
  translates :name, :logo_formatted_name, :acronym, :description, :about_us

  include Featurable

  mount_uploader :logo, LogoUploader

  searchable title: :name,
             acronym: :acronym,
             link: :search_link,
             content: :indexable_content,
             description: :description,
             boost_phrases: :acronym,
             slug: :slug,
             organisation_state: :govuk_status

  extend FriendlyId
  friendly_id

  before_destroy { |r| r.destroyable? }
  after_save :ensure_analytics_identifier

  def custom_logo_selected?
    organisation_logo_type_id == OrganisationLogoType::CustomLogo.id
  end

  scope :excluding_govuk_status_closed, -> { where("govuk_status != 'closed'") }
  scope :closed, -> { where(govuk_status: "closed") }
  scope :with_statistics_announcements, -> { joins("INNER JOIN statistics_announcements ON statistics_announcements.organisation_id = organisations.id").group("organisations.id") }

  def self.grouped_by_type(locale = I18n.locale)
    Rails.cache.fetch("filter_options/organisations/#{locale}", expires_in: 30.minutes) do
      all_orgs = self.with_published_editions.with_translations(locale).ordered_by_name_ignoring_prefix

      closed_orgs, open_orgs = all_orgs.partition(&:closed?)
      ministerial_orgs, other_orgs = open_orgs.partition(&:ministerial_department?)

      {
        'Ministerial departments' => ministerial_orgs.map { |o| [o.name, o.slug] },
        'Other departments & public bodies' => other_orgs.map { |o| [o.name, o.slug] },
        'Closed organisations' => closed_orgs.map { |o| [o.name, o.slug] }
      }
    end
  end

  def ensure_analytics_identifier
    unless analytics_identifier.present?
      update_column(:analytics_identifier, organisation_type.analytics_prefix + self.id.to_s)
    end
  end

  def organisation_logo_type
    OrganisationLogoType.find_by_id(organisation_logo_type_id)
  end

  def organisation_logo_type=(organisation_logo_type)
    self.organisation_logo_type_id = organisation_logo_type && organisation_logo_type.id
  end

  def organisation_brand_colour
    OrganisationBrandColour.find_by_id(organisation_brand_colour_id)
  end

  def organisation_brand_colour=(organisation_brand_colour)
    self.organisation_brand_colour_id = organisation_brand_colour && organisation_brand_colour.id
  end

  def self.alphabetical(locale = I18n.locale)
    with_translations(locale).order('organisation_translations.name ASC')
  end

  def self.ordered_by_name_ignoring_prefix
    all.sort_by { |o| o.name_without_prefix }
  end

  def self.with_published_editions
    where("exists (
      SELECT 1 FROM `editions`
      INNER JOIN `edition_organisations` ON `edition_organisations`.`edition_id` = `editions`.`id`
      WHERE `editions`.`state` = 'published'
      AND (edition_organisations.organisation_id = organisations.id)
    )")
  end

  def self.parent_organisations
    where("not exists (" +
      "select * from organisational_relationships " +
      "where organisational_relationships.child_organisation_id=organisations.id)")
  end

  def sub_organisations
    child_organisations.where(organisation_type_key: :sub_organisation)
  end

  def live?
    govuk_status == 'live'
  end

  def joining?
    govuk_status == 'joining'
  end

  def transitioning?
    govuk_status == 'transitioning'
  end

  def closed?
    govuk_status == 'closed'
  end

  def exempt?
    govuk_status == 'exempt'
  end

  def name_without_prefix
    name.gsub(/^The/, "").strip
  end

  def display_name
    [acronym, name].detect { |s| s.present? }
  end

  def select_name
    [name, ("(#{acronym})" if acronym.present?)].compact.join(' ')
  end

  def indexable_content
    Govspeak::Document.new("#{description} #{about_us}").to_text
  end

  def search_link
    # This should be organisation_path(self), but we can't use that because friendly_id's #to_param returns
    # the old value of the slug (e.g. nil for a new record) if the record is dirty, and apparently the record
    # is still marked as dirty during after_save callbacks.
    Whitehall.url_maker.organisation_path(slug)
  end

  def published_speeches
    ministerial_roles.map { |mr| mr.speeches.published }.flatten.uniq
  end

  def published_editions
    editions.published
  end

  def scheduled_editions
    editions.scheduled.order('scheduled_publication ASC')
  end

  def published_announcements
    published_editions.announcements
  end

  def published_consultations
    published_editions.consultations
  end

  def published_detailed_guides
    published_editions.detailed_guides
  end

  def published_policies
    published_editions.policies
  end

  def published_non_statistics_publications
    published_editions.non_statistical_publications
  end

  def published_statistics_publications
    published_editions.statistical_publications
  end

  def corporate_publications
    editions.corporate_publications
  end

  def destroyable?
    child_organisations.none? && organisation_roles.none? && !new_record?
  end

  def provides_alternative_formats?
    persisted? && Edition.where(alternative_format_provider_id: self.id).any?
  end

  def requires_alternative_format?
    (! closed?) && provides_alternative_formats?
  end

  def unused_corporate_information_page_types
    CorporateInformationPageType.all - corporate_information_pages.map(&:type)
  end

  def has_published_publications_of_type?(publication_type)
    published_editions.where(publication_type_id: publication_type.id).any?
  end

  def to_s
    name
  end

  def alternate_style_top_tasks
    case slug
    when 'driver-and-vehicle-licensing-agency'
      {
        services_in: [
          {
            path: '/browse/driving',
            text: 'Driving and transport',
          }
        ],
        prominent: [
          {
            path: '/tax-disc',
            text: 'Get a tax disc for your vehicle',
            description: 'You will need your numberplate, a credit/debit card and either your tax disc renewal reminder or your vehicle logbook.'
          },
          {
            path: '/vehicle-registration-certificate-v5c-log-book',
            text: 'Get a V5C (logbook)',
            description: 'Apply by phone or post to get a replacement V5C vehicle registration certificate (log book). There is a £25 fee.'
          }
        ],
        top_tasks: [
          {
            path: '/register-sorn-statutory-off-road-notification',
            text: 'Make a SORN'
          },
          {
            path: '/change-address-driving-licence',
            text: 'Change the address on your driving licence'
          },
          {
            path: '/get-vehicle-information-from-dvla',
            text: 'Get vehicle information from DVLA'
          }
        ]
      }
    when 'uk-visas-and-immigration'
      {
        services_in: [
          {
            path: '/immigration-operational-guidance',
            text: "UKVI's operational guidance"
          },
          {
            path: '/government/collections/immigration-rules',
            text: 'The current Immigration Rules'
          },
        ],
        prominent: [
          {
            path: '/visas-immigration',
            text: 'Visas, settlement and asylum',
            description: 'Information on different UK visas, how to settle in the UK and claiming asylum.'
          },
          {
            path: '/browse/visas-immigration/eu-eea-commonwealth',
            text: 'European nationals',
            description: 'Living and working in the UK for EU and EEA nationals, their partners and family.'
          },
          {
            path: '/browse/citizenship/citizenship',
            text: 'British citizenship',
            description: 'How to become a British citizen and types of UK nationality.'
          }
        ]
      }
    when 'environment-agency'
      {
        services_in: [
          {
            path: '/environmental-management',
            text: 'Comply with environmental regulations'
          },
        ],
        prominent: [
          {
            path: '/check-if-youre-at-risk-of-flooding',
            text: 'Flood warnings',
            description: 'Check flood warnings in your area'
          },
          {
            path: '/browse/environment-countryside/recycling-waste-management',
            text: 'Business and commercial waste',
            description: 'What to do with waste you produce in your business'
          },
          {
            path: '/browse/environment-countryside',
            text: 'Environment, boating and fishing',
            description: 'Buy your rod licence online and register your boat'
          },
        ]
      }
    else
      {}  
    end
  end

  private

  def sub_organisations_must_have_a_parent
    if organisation_type && organisation_type.sub_organisation?
      if parent_organisations.empty?
        errors[:parent_organisations] << "must not be empty for sub-organisations"
      end
    end
  end
end
