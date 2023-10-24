class Organisation < ApplicationRecord
  include DateValidation
  include PublishesToPublishingApi
  include Searchable
  include Organisation::OrganisationSearchIndexConcern
  include Organisation::OrganisationTypeConcern

  date_attributes(:closed_at)

  DEFAULT_JOBS_URL = "https://www.civilservicejobs.service.gov.uk/csr".freeze
  FEATURED_DOCUMENTS_DISPLAY_LIMIT = 6

  belongs_to :default_news_image, class_name: "DefaultNewsOrganisationImageData", foreign_key: :default_news_organisation_image_data_id
  belongs_to :default_news_image_new, class_name: "FeaturedImageData", foreign_key: :featured_image_data_id

  has_many :assets,
           as: :assetable,
           inverse_of: :assetable
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
  # This include is dependant on the above has_many
  include HasCorporateInformationPages

  has_many :editions, through: :edition_organisations

  has_many :statistics_announcement_organisations, inverse_of: :organisation, dependent: :destroy
  has_many :statistics_announcements, through: :statistics_announcement_organisations

  has_many :organisation_roles, inverse_of: :organisation
  has_many :roles, through: :organisation_roles
  has_many :ministerial_roles,
           -> { where("roles.whip_organisation_id IS null") },
           class_name: "MinisterialRole",
           through: :organisation_roles,
           source: :role
  has_many :ministerial_whip_roles,
           -> { where("roles.whip_organisation_id IS NOT null") },
           class_name: "MinisterialRole",
           through: :organisation_roles,
           source: :role
  has_many :management_roles,
           -> { where("type = 'BoardMemberRole' OR type = 'ChiefScientificAdvisorRole'") },
           through: :organisation_roles,
           source: :role
  has_many :military_roles,
           class_name: "MilitaryRole",
           through: :organisation_roles,
           source: :role
  has_many :traffic_commissioner_roles,
           class_name: "TrafficCommissionerRole",
           through: :organisation_roles,
           source: :role
  has_many :chief_professional_officer_roles,
           class_name: "ChiefProfessionalOfficerRole",
           through: :organisation_roles,
           source: :role
  has_many :special_representative_roles,
           class_name: "SpecialRepresentativeRole",
           through: :organisation_roles,
           source: :role
  has_many :ministerial_role_appointments,
           class_name: "RoleAppointment",
           through: :ministerial_roles,
           source: :role_appointments
  has_many :ministerial_whip_role_appointments,
           class_name: "RoleAppointment",
           through: :ministerial_whip_roles,
           source: :role_appointments
  has_many :judge_roles,
           class_name: "JudgeRole",
           through: :organisation_roles,
           source: :role

  has_many :people, through: :roles

  has_many :topical_event_organisations,
           -> { order("topical_event_organisations.ordering") },
           dependent: :destroy
  has_many :topical_events, through: :topical_event_organisations

  has_many :topical_events,
           -> { order("topical_event_organisations.ordering") },
           through: :topical_event_organisations

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

  has_many :promotional_features, -> { order(:ordering) }

  has_many :featured_links, -> { order(:created_at) }, as: :linkable, dependent: :destroy
  accepts_nested_attributes_for :featured_links, reject_if: ->(attributes) { attributes["url"].blank? }, allow_destroy: true
  validates :homepage_type, inclusion: { in: %w[news service] }

  accepts_nested_attributes_for :default_news_image, reject_if: :all_blank
  accepts_nested_attributes_for :organisation_roles
  accepts_nested_attributes_for :edition_organisations
  accepts_nested_attributes_for :topical_event_organisations, reject_if: ->(attributes) { attributes["topical_event_id"].blank? }, allow_destroy: true
  accepts_nested_attributes_for :offsite_links

  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates_with SafeHtmlValidator
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :logo_formatted_name, presence: true
  validates :url, :organisation_chart_url, :custom_jobs_url, uri: true, allow_blank: true
  validates :alternative_format_contact_email, email_format: { allow_blank: true }
  validates :alternative_format_contact_email,
            presence: {
              if: :requires_alternative_format?,
              message: "can't be blank as there are editions which use this organisation as the alternative format provider",
            }
  validates :govuk_status, presence: true, inclusion: { in: %w[live joining exempt transitioning closed] }
  validates :govuk_closed_status, inclusion: { in: %w[no_longer_exists replaced split merged changed_name left_gov devolved] }, presence: true, if: :closed?
  validates :organisation_logo_type_id, presence: true
  validates :logo, presence: true, if: :custom_logo_selected?

  validate :exactly_one_superseding_organisation, if: proc { |organisation| organisation.replaced? || organisation.merged? || organisation.changed_name? }
  validate :at_least_two_superseding_organisations, if: :split?
  validate :exactly_one_devolved_superseding_organisation, if: :devolved?

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
             organisations: :search_parent_organisations,
             parent_organisations: :search_parent_organisations,
             child_organisations: :search_child_organisations,
             superseded_organisations: :search_superseded_organisations,
             superseding_organisations: :search_superseding_organisations,
             boost_phrases: :acronym,
             slug: :slug,
             organisation_closed_state: :govuk_closed_status,
             organisation_state: :searchable_govuk_status,
             organisation_type: :organisation_type_key,
             organisation_crest: :organisation_crest,
             organisation_brand: :organisation_brand,
             logo_formatted_title: :logo_formatted_name,
             logo_url: :logo_url,
             analytics_identifier: :analytics_identifier,
             closed_at: :closed_at,
             public_timestamp: :updated_at

  extend FriendlyId
  friendly_id

  before_destroy { |r| throw :abort unless r.destroyable? }
  after_save :ensure_analytics_identifier
  after_save :republish_how_government_works_page_to_publishing_api, :republish_ministers_index_page_to_publishing_api, :republish_organisations_index_page_to_publishing_api
  after_destroy :republish_ministers_index_page_to_publishing_api, :republish_organisations_index_page_to_publishing_api

  after_save do
    # If the organisation has an about us page and the chart URL changes we need
    # to republish the about us page as it contains the chart URL.
    if saved_change_to_organisation_chart_url? && about_us.present?
      PublishingApiDocumentRepublishingWorker
        .perform_async(about_us.document_id)
    end

    # If the default news organisation image changes we need to republish all
    # news articles belonging to the organisation
    if saved_change_to_default_news_organisation_image_data_id?
      documents = NewsArticle
        .in_organisation(self)
        .includes(:images)
        .where(images: { id: nil })
        .map(&:document)

      documents.each { |d| Whitehall::PublishingApi.republish_document_async(d) }
    end

    # If the alternative format contact email is changed, we need to republish
    # all attachments belonging to the organisation
    if saved_change_to_alternative_format_contact_email?
      documents = Document.live.where(editions: { alternative_format_provider_id: self })
      documents.find_each { |d| Whitehall::PublishingApi.republish_document_async(d, bulk: true) }
    end
  end

  def republish_how_government_works_page_to_publishing_api
    PresentPageToPublishingApi.new.publish(PublishingApi::HowGovernmentWorksPresenter)
  end

  def republish_ministers_index_page_to_publishing_api
    PresentPageToPublishingApi.new.publish(PublishingApi::MinistersIndexPresenter) if ministerial_department?
  end

  def republish_organisations_index_page_to_publishing_api
    PresentPageToPublishingApi.new.publish(PublishingApi::OrganisationsIndexPresenter)
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

  scope :excluding_govuk_status_closed, -> { where("govuk_status != 'closed'") }
  scope :closed, -> { where(govuk_status: "closed") }
  scope :with_statistics_announcements,
        lambda {
          joins(:statistics_announcement_organisations)
            .group("statistics_announcement_organisations.organisation_id")
        }

  def ensure_analytics_identifier
    if analytics_identifier.blank?
      update_column(:analytics_identifier, organisation_type.analytics_prefix + id.to_s)
    end
  end

  def organisation_logo_type
    OrganisationLogoType.find_by_id(organisation_logo_type_id)
  end

  def organisation_logo_type=(organisation_logo_type)
    self.organisation_logo_type_id = organisation_logo_type && organisation_logo_type.id
  end

  def organisation_crest
    organisation_logo_type.try(:class_name)
  end

  def organisation_brand_colour
    OrganisationBrandColour.find_by_id(organisation_brand_colour_id)
  end

  def organisation_brand_colour=(organisation_brand_colour)
    self.organisation_brand_colour_id = organisation_brand_colour && organisation_brand_colour.id
  end

  def organisation_brand
    organisation_brand_colour.try(:class_name)
  end

  def self.alphabetical(locale = I18n.locale)
    with_translations(locale).order("organisation_translations.name ASC")
  end

  def self.ordered_by_name_ignoring_prefix
    all.sort_by(&:name_without_prefix)
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
    where("not exists (" \
      "select * from organisational_relationships " \
      "where organisational_relationships.child_organisation_id=organisations.id)")
  end

  def sub_organisations
    child_organisations.where(organisation_type_key: :sub_organisation)
  end

  def searchable_govuk_status
    if closed? && devolved?
      "devolved"
    else
      govuk_status
    end
  end

  def logo_url
    logo.try(:url)
  end

  def live?
    govuk_status == "live"
  end

  def joining?
    govuk_status == "joining"
  end

  def transitioning?
    govuk_status == "transitioning"
  end

  def closed?
    govuk_status == "closed"
  end

  def exempt?
    govuk_status == "exempt"
  end

  def no_longer_exists?
    govuk_closed_status == "no_longer_exists"
  end

  def replaced?
    govuk_closed_status == "replaced"
  end

  def split?
    govuk_closed_status == "split"
  end

  def merged?
    govuk_closed_status == "merged"
  end

  def changed_name?
    govuk_closed_status == "changed_name"
  end

  def left_gov?
    govuk_closed_status == "left_gov"
  end

  def devolved?
    govuk_closed_status == "devolved"
  end

  def superseded_by_devolved_administration?
    devolved? && superseding_organisations.map(&:organisation_type_key).include?(:devolved_administration)
  end

  def name_without_prefix
    name.gsub(/^The/, "").strip
  end

  def display_name
    [acronym, name].detect(&:present?)
  end

  def select_name
    [name, ("(#{acronym})" if acronym.present?)].compact.join(" ")
  end

  def jobs_url
    custom_jobs_url.presence || DEFAULT_JOBS_URL
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

  def search_link
    base_path
  end

  def search_parent_organisations
    parent_organisations.map(&:slug)
  end

  def search_child_organisations
    child_organisations.map(&:slug)
  end

  def search_superseded_organisations
    superseded_organisations.map(&:slug)
  end

  def search_superseding_organisations
    superseding_organisations.map(&:slug)
  end

  def published_speeches
    ministerial_roles.map { |mr| mr.speeches.published }.flatten.uniq
  end

  def published_editions
    editions.published
  end

  delegate :corporate_publications, to: :editions

  def destroyable?
    child_organisations.none? && organisation_roles.none? && !new_record?
  end

  def provides_alternative_formats?
    persisted? && Edition.where(alternative_format_provider_id: id).any?
  end

  def requires_alternative_format?
    !closed? && provides_alternative_formats?
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
    homepage_type == "news"
  end

  def service_priority_homepage?
    homepage_type == "service"
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
    %w[
      charity-commission
      hm-revenue-customs
    ]
  end

  def reorder_promotional_features(new_order)
    promotional_features_orderings = promotional_features.map(&:ordering)

    new_order.each do |promotional_feature_row|
      id, ordering = promotional_feature_row
      promotional_feature = promotional_features.find(id)
      promotional_feature.update!(ordering: promotional_features_orderings[ordering.to_i - 1])
    end
  end

  def base_path
    if court_or_hmcts_tribunal?
      "/courts-tribunals/#{slug}"
    else
      "/government/organisations/#{slug}"
    end
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def link_to_section_on_organisation_list_page
    append_url_options("/government/organisations", anchor: slug)
  end

  def public_url(options = {})
    website_root = if options[:draft]
                     Plek.external_url_for("draft-origin")
                   else
                     Plek.website_root
                   end

    website_root + public_path(options)
  end

  def publishing_api_presenter
    PublishingApi::OrganisationPresenter
  end

  def all_asset_variants_uploaded?
    asset_variants = assets.map(&:variant).map(&:to_sym)
    required_variants = LogoUploader.versions.keys.push(:original)

    (required_variants - asset_variants).empty?
  end

private

  def organisations_with_scoped_search
    %w[
      competition-and-markets-authority
      environment-agency
      land-registry
      legal-aid-agency
    ]
  end
end
