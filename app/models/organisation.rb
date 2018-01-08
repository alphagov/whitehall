class Organisation < ApplicationRecord
  include PublishesToPublishingApi
  include Searchable
  include MinisterialRole::MinisterialRoleReindexingConcern
  include Organisation::OrganisationSearchIndexConcern
  include Organisation::OrganisationTypeConcern
  include HasCorporateInformationPages

  DEFAULT_JOBS_URL = 'https://www.civilservicejobs.service.gov.uk/csr'

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

  has_many :edition_organisations, dependent: :destroy, inverse_of: :organisation
  has_many :editions, through: :edition_organisations

  has_many :statistics_announcement_organisations, inverse_of: :organisation, dependent: :destroy
  has_many :statistics_announcements, through: :statistics_announcement_organisations

  has_many :organisation_roles, inverse_of: :organisation
  has_many :roles, through: :organisation_roles
  has_many :ministerial_roles,
            -> { where("roles.whip_organisation_id IS null") },
            class_name: 'MinisterialRole',
            through: :organisation_roles,
            source: :role
  has_many :ministerial_whip_roles,
            -> { where("roles.whip_organisation_id IS NOT null") },
            class_name: 'MinisterialRole',
            through: :organisation_roles,
            source: :role
  has_many :management_roles,
            -> { where("type = 'BoardMemberRole' OR type = 'ChiefScientificAdvisorRole'") },
            through: :organisation_roles,
            source: :role
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
  has_many :judge_roles,
           class_name: 'JudgeRole',
           through: :organisation_roles,
           source: :role

  has_many :people, through: :roles

  has_many :organisation_classifications,
           -> { order('organisation_classifications.ordering') },
           dependent: :destroy

  # DID YOU MEAN: Policy Area?
  # "Policy area" is the newer name for "topic"
  # (https://www.gov.uk/government/topics)
  # "Topic" is the newer name for "specialist sector"
  # (https://www.gov.uk/topic)
  # You can help improve this code by renaming all usages of this field to use
  # the new terminology.
  has_many :topics,
           -> { order('organisation_classifications.ordering') },
           through: :organisation_classifications
  has_many :classifications, through: :organisation_classifications

  has_many :users, foreign_key: :organisation_slug, primary_key: :slug, dependent: :nullify

  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :social_media_accounts,
           -> { includes(:social_media_service) },
           as: :socialable,
           dependent: :destroy

  has_many :sponsorships, dependent: :destroy
  has_many :sponsored_worldwide_organisations, through: :sponsorships, source: :worldwide_organisation

  has_many :financial_reports

  has_and_belongs_to_many :superseding_organisations, class_name: "Organisation", foreign_key: :superseded_organisation_id, join_table: :organisation_supersedings, association_foreign_key: :superseding_organisation_id
  has_and_belongs_to_many :superseded_organisations, class_name: "Organisation", foreign_key: :superseding_organisation_id, join_table: :organisation_supersedings, association_foreign_key: :superseded_organisation_id

  has_many :offsite_links, as: :parent

  has_many :featured_policies

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

  has_many :featured_links, -> { order(:created_at) }, as: :linkable, dependent: :destroy
  accepts_nested_attributes_for :featured_links, reject_if: ->attributes { attributes['url'].blank? }, allow_destroy: true
  validates :homepage_type, inclusion: {in: %w{news service}}

  accepts_nested_attributes_for :default_news_image, reject_if: :all_blank
  accepts_nested_attributes_for :organisation_roles
  accepts_nested_attributes_for :edition_organisations
  accepts_nested_attributes_for :organisation_classifications, reject_if: ->attributes { attributes['classification_id'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :offsite_links
  accepts_nested_attributes_for :featured_policies

  validates :slug, presence: true, uniqueness: true
  validates_with SafeHtmlValidator
  validates :name, presence: true, uniqueness: true
  validates :logo_formatted_name, presence: true
  validates :url, :organisation_chart_url, :custom_jobs_url, uri: true, allow_blank: true
  validates :alternative_format_contact_email, email_format: {allow_blank: true}
  validates :alternative_format_contact_email, presence: {
    if: :requires_alternative_format?,
    message: "can't be blank as there are editions which use this organisation as the alternative format provider",
  }
  validates :govuk_status, inclusion: {in: %w{live joining exempt transitioning closed}}
  validates :govuk_closed_status, inclusion: {in: %w{no_longer_exists replaced split merged changed_name left_gov devolved}}, presence: true, if: :closed?
  validates :organisation_logo_type_id, presence: true
  validates :logo, presence: true, if: :custom_logo_selected?

  validate :exactly_one_superseding_organisation, if: Proc.new { |organisation| organisation.replaced? || organisation.merged? || organisation.changed_name? }
  validate :at_least_two_superseding_organisations, if: :split?
  validate :exactly_one_devolved_superseding_organisation, if: :devolved?
  validate :exempt_organisation_does_not_have_custom_logo

  delegate :ministerial_department?, to: :type
  delegate :devolved_administration?, to: :type

  include TranslatableModel
  translates :name, :logo_formatted_name, :acronym

  include Featurable

  mount_uploader :logo, LogoUploader

  searchable title: :title_for_search,
             acronym: :acronym,
             link: :search_link,
             content: :indexable_content,
             description: :description_for_search,
             organisations: :search_organisations,
             boost_phrases: :acronym,
             slug: :slug,
             organisation_state: :searchable_govuk_status,
             organisation_type: :organisation_type_key

  extend FriendlyId
  friendly_id

  before_destroy { |r| throw :abort unless r.destroyable? }
  after_save :ensure_analytics_identifier

  after_save do
    # If the organisation has an about us page and the chart URL changes we need
    # to republish the about us page as it contains the chart URL.
    if organisation_chart_url_changed? && about_us.present?
      PublishingApiDocumentRepublishingWorker
        .perform_async(about_us.document_id)
    end

    # If the default news organisation image changes we need to republish all
    # news articles belonging to the organisation
    if default_news_organisation_image_data_id_changed?
      documents = NewsArticle
        .in_organisation(self)
        .includes(:images)
        .where(images: { id: nil })
        .map(&:document)

      documents.each { |d| Whitehall::PublishingApi.republish_document_async(d) }
    end
  end

  def custom_logo_selected?
    organisation_logo_type_id == OrganisationLogoType::CustomLogo.id
  end

  def exactly_one_superseding_organisation
    if superseding_organisations.size != 1
      errors.add(:base, "Please add exactly one superseding organisation for this closed status.")
    end
  end

  def at_least_two_superseding_organisations
    if superseding_organisations.size < 2
      errors.add(:base, "Please add at least two superseding organisations for this closed status.")
    end
  end

  def exactly_one_devolved_superseding_organisation
    if superseding_organisations.size != 1 || !superseding_organisations.first.devolved_administration?
      errors.add(:base, "Please add exactly one devolved superseding organisation for this closed status.")
    end
  end

  def exempt_organisation_does_not_have_custom_logo
    if exempt? && organisation_logo_type == OrganisationLogoType::CustomLogo
      errors.add(:base, "Organisations which are exempt from GOV.UK cannot have a custom logo.")
    end
  end

  scope :excluding_govuk_status_closed, -> { where("govuk_status != 'closed'") }
  scope :closed, -> { where(govuk_status: "closed") }
  scope :with_statistics_announcements, -> {
    joins(:statistics_announcement_organisations)
      .group('statistics_announcement_organisations.organisation_id')
  }

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

  def searchable_govuk_status
    if closed? && devolved?
      'devolved'
    else
      govuk_status
    end
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

  def no_longer_exists?
    govuk_closed_status == 'no_longer_exists'
  end

  def replaced?
    govuk_closed_status == 'replaced'
  end

  def split?
    govuk_closed_status == 'split'
  end

  def merged?
    govuk_closed_status == 'merged'
  end

  def changed_name?
    govuk_closed_status == 'changed_name'
  end

  def left_gov?
    govuk_closed_status == 'left_gov'
  end

  def devolved?
    govuk_closed_status == 'devolved'
  end

  def superseded_by_devolved_administration?
    devolved? && superseding_organisations.map(&:organisation_type_key).include?(:devolved_administration)
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

  def jobs_url
    custom_jobs_url.present? ? custom_jobs_url : DEFAULT_JOBS_URL
  end

  def indexable_content
    Govspeak::Document.new("#{summary} #{body}").to_text
  end

  def description_for_search
    description = Govspeak::Document.new(summary).to_text

    if !closed?
      "The home of #{name} on GOV.UK. #{description}"
    else
      description
    end
  end

  def title_for_search
    if closed?
      "Closed organisation: #{name}"
    else
      name
    end
  end

  def base_path
    Whitehall.url_maker.organisation_path(self)
  end

  def search_link
    base_path
  end

  def search_organisations
    parent_organisations.map(&:slug)
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

  def published_non_corporate_information_pages
    published_editions.without_editions_of_type(CorporateInformationPage)
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
    (!closed?) && provides_alternative_formats?
  end

  def has_published_publications_of_type?(publication_type)
    published_editions.where(publication_type_id: publication_type.id).any?
  end

  def has_services_and_information_link?
    organisations_with_services_and_information_link.include?(slug)
  end

  def has_scoped_search?
    organisations_with_scoped_search.include?(slug)
  end

  def has_child_organisation?(child)
    child_organisations.exists?(id: child.id)
  end

  def to_s
    name
  end

  def news_priority_homepage?
    homepage_type == 'news'
  end

  def service_priority_homepage?
    homepage_type == 'service'
  end

  def visible_featured_links_count
    if service_priority_homepage?
      10
    else
      FeaturedLink::DEFAULT_SET_SIZE
    end
  end

  def visible_featured_links
    featured_links.limit(visible_featured_links_count)
  end

  def organisations_with_services_and_information_link
    %w{
      charity-commission
      department-for-education
      department-for-environment-food-rural-affairs
      driver-and-vehicle-standards-agency
      environment-agency
      high-speed-two-limited
      highways-england
      hm-revenue-customs
      marine-management-organisation
      maritime-and-coastguard-agency
      medicines-and-healthcare-products-regulatory-agency
      natural-england
      planning-inspectorate
    }
  end

private

  def organisations_with_scoped_search
    [
      'competition-and-markets-authority',
      'environment-agency',
      'land-registry',
      'legal-aid-agency',
    ]
  end

  def sub_organisations_must_have_a_parent
    if organisation_type && organisation_type.sub_organisation?
      if parent_organisations.empty?
        errors[:parent_organisations] << "must not be empty for sub-organisations"
      end
    end
  end
end
