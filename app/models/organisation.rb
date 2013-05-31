require 'validators/url_validator.rb'

class Organisation < ActiveRecord::Base
  include Searchable

  belongs_to :organisation_type
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

  has_many :edition_organisations,
            dependent: :destroy
  has_many :featured_edition_organisations,
            class_name: "EditionOrganisation",
            include: :edition,
            conditions: { "edition_organisations" => {"featured" => true},
                          "editions" => {state: "published"}},
            order: "edition_organisations.ordering ASC"
  has_many :editions,
            through: :edition_organisations
  has_many :published_editions,
            through: :edition_organisations,
            class_name: "Edition",
            conditions: { state: "published" },
            source: :edition
  has_many :force_published_editions,
            through: :edition_organisations,
            class_name: "Edition",
            conditions: { state: "published", force_published: true },
            source: :edition
  has_many :corporate_publications,
            through: :edition_organisations,
            class_name: "Publication",
            conditions: { "editions.publication_type_id" => PublicationType::CorporateReport.id },
            source: :edition
  has_many :featured_editions,
            through: :featured_edition_organisations,
            source: :edition,
            order: "edition_organisations.ordering ASC"
  has_many :detailed_guides,
            through: :edition_organisations,
            class_name: "DetailedGuide",
            source: :edition
  has_many :published_detailed_guides,
            through: :edition_organisations,
            class_name: "DetailedGuide",
            conditions: { "editions.state" => "published" },
            source: :edition
  has_many :published_publications,
            through: :edition_organisations,
            class_name: "Publicationesque",
            conditions: { "editions.state" => "published" },
            source: :edition
  has_many :published_consultations,
            through: :edition_organisations,
            class_name: "Consultation",
            conditions: { "editions.state" => "published" },
            source: :edition
  has_many :published_non_statistics_publications,
            through: :edition_organisations,
            class_name: "Publication",
            conditions: [ "editions.state='published' AND editions.publication_type_id NOT IN (?)",
              PublicationType.statistical.map(&:id) ],
            source: :edition
  has_many :published_statistics_publications,
            through: :edition_organisations,
            class_name: "Publication",
            conditions: [ "editions.state='published' AND editions.publication_type_id IN (?)",
              PublicationType.statistical.map(&:id) ],
            source: :edition
  has_many :published_announcements,
            through: :edition_organisations,
            class_name: "Announcement",
            conditions: { "editions.state" => "published"},
            source: :edition
  has_many :policies,
            through: :edition_organisations,
            class_name: "Policy",
            source: :edition
  has_many :published_policies,
            through: :edition_organisations,
            class_name: "Policy",
            conditions: { "editions.state" => "published"},
            source: :edition
  has_many :scheduled_editions,
            through: :edition_organisations,
            class_name: "Edition",
            conditions: { state: "scheduled" },
            order: "scheduled_publication ASC",
            source: :edition

  has_many :document_series

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

  has_many :users, dependent: :nullify

  has_many :organisation_mainstream_links,
            dependent: :destroy
  has_many :mainstream_links,
            through: :organisation_mainstream_links,
            dependent: :destroy

  has_many :corporate_information_pages, as: :organisation, dependent: :destroy

  has_many :contacts, as: :contactable, dependent: :destroy
  has_many :social_media_accounts, as: :socialable, dependent: :destroy, include: [:social_media_service]

  has_many :sponsorships, dependent: :destroy
  has_many :sponsored_worldwide_organisations, through: :sponsorships, source: :worldwide_organisation

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

  accepts_nested_attributes_for :default_news_image, reject_if: :all_blank
  accepts_nested_attributes_for :mainstream_links, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :organisation_roles
  accepts_nested_attributes_for :edition_organisations
  accepts_nested_attributes_for :organisation_classifications, reject_if: -> attributes { attributes['classification_id'].blank? }, allow_destroy: true
  accepts_nested_attributes_for :organisation_mainstream_categories, reject_if: -> attributes { attributes['mainstream_category_id'].blank? }, allow_destroy: true

  validates_with SafeHtmlValidator
  validates :name, presence: true, uniqueness: true
  validates :organisation_type_id, presence: true
  validates :logo_formatted_name, presence: true
  validates :url, url: true, allow_blank: true
  validates :alternative_format_contact_email, email_format: {allow_blank: true}
  validates :alternative_format_contact_email, presence: {
    if: :provides_alternative_formats?,
    message: "can't be blank as there are editions which use this organisation as the alternative format provider"}
  validates :govuk_status, inclusion: {in: %w{live joining exempt transitioning}}
  validates :organisation_logo_type_id, presence: true
  validate :sub_organisations_must_have_a_parent

  include TranslatableModel
  translates :name, :logo_formatted_name, :acronym, :description, :about_us

  include Featurable

  searchable title: :select_name,
             link: :search_link,
             content: :indexable_content,
             boost_phrases: :acronym

  extend FriendlyId
  friendly_id

  before_destroy { |r| r.destroyable? }
  after_save :ensure_analytics_identifier

  def ensure_analytics_identifier
    unless analytics_identifier.present?
      update_attribute(:analytics_identifier, organisation_type.analytics_prefix + self.id.to_s)
    end
  end

  def organisation_logo_type
    OrganisationLogoType.find_by_id(organisation_logo_type_id)
  end

  def organisation_logo_type=(organisation_logo_type)
    self.organisation_logo_type_id = organisation_logo_type && organisation_logo_type.id
  end

  def self.alphabetical(locale = I18n.locale)
    with_translations(locale).order('organisation_translations.name ASC')
  end

  def self.ordered_by_name_ignoring_prefix
    all.sort_by { |o| o.name_without_prefix }
  end

  def self.in_listing_order
    joins(:organisation_type).all.sort_by { |o| o.organisation_type.listing_order }
  end

  def self.ministerial_departments
    where("organisation_type_id = ?" , OrganisationType.ministerial_department)
  end

  def self.non_ministerial_departments
    where("organisation_type_id != ?" , OrganisationType.ministerial_department)
  end

  def self.with_published_editions(type=nil)
    if type
      klass = type.to_s.classify.constantize
      type_clause = { type: (klass.respond_to?(:sti_names) ? klass.sti_names : klass.name) }
    else
      type_class = ''
    end

    published_editions_conditions = Edition.joins(:edition_organisations).
                                            published.
                                            where(type_clause).
                                            where("edition_organisations.organisation_id = organisations.id").
                                            select(1).to_sql

    where("exists (#{published_editions_conditions})")
  end

  def agencies_and_public_bodies
    @agencies_and_public_bodies ||= child_organisations.with_translations.includes(:organisation_type).merge(OrganisationType.agency_or_public_body).all
  end

  def agencies_and_public_bodies_by_type
    agencies_and_public_bodies.group_by(&:organisation_type).sort_by { |type, department| type.listing_order }
  end

  def sub_organisations
    child_organisations.joins(:organisation_type).merge(OrganisationType.sub_organisation)
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

  def topics_with_content
    topics.with_content
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
    "#{description} #{about_us_without_markup}"
  end

  def about_us_without_markup
    Govspeak::Document.new(about_us).to_text
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

  def department?
    organisation_type.department?
  end

  def executive_office?
    organisation_type.executive_office?
  end

  def self.departments
    where(organisation_type_id: OrganisationType.departmental_types).includes(:translations)
  end

  def self.executive_offices
    where(organisation_type_id: OrganisationType.executive_office)
  end

  def self.parent_organisations
    where("not exists (" +
      "select * from organisational_relationships " +
      "where organisational_relationships.child_organisation_id=organisations.id)")
  end

  def destroyable?
    child_organisations.none? && organisation_roles.none? && !new_record?
  end

  def provides_alternative_formats?
    persisted? && Edition.where(alternative_format_provider_id: self.id).any?
  end

  def unused_corporate_information_page_types
    CorporateInformationPageType.all - corporate_information_pages.map(&:type)
  end

  def has_published_publications_of_type?(publication_type)
    published_publications.where("editions.publication_type_id" => publication_type.id).any?
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
