require 'validators/url_validator.rb'

class Organisation < ActiveRecord::Base
  include Searchable
  include Rails.application.routes.url_helpers

  belongs_to :organisation_type

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
  has_many :published_announcements,
            through: :edition_organisations,
            class_name: "Announcement",
            conditions: { "editions.state" => "published"},
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
            source: :role
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
  has_many :special_representative_roles,
            class_name: 'SpecialRepresentativeRole',
            through: :organisation_roles,
            source: :role

  has_many :people, through: :roles

  has_many :organisation_classifications, dependent: :destroy, order: 'organisation_classifications.ordering'
  has_many :topics, through: :organisation_classifications, order: 'organisation_classifications.ordering'
  has_many :classifications, through: :organisation_classifications

  has_many :users, dependent: :nullify

  has_many :contacts, dependent: :destroy
  has_many :social_media_accounts, as: :socialable, dependent: :destroy
  has_many :organisation_mainstream_links, dependent: :destroy

  has_many :corporate_information_pages, dependent: :destroy

  accepts_nested_attributes_for :contacts, reject_if: :contact_and_contact_numbers_are_blank
  accepts_nested_attributes_for :social_media_accounts, allow_destroy: true
  accepts_nested_attributes_for :organisation_mainstream_links, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :organisation_roles
  accepts_nested_attributes_for :edition_organisations
  accepts_nested_attributes_for :organisation_classifications, reject_if: -> attributes { attributes['classification_id'].blank? }, allow_destroy: true

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

  default_scope order(arel_table[:name])

  searchable title: :name,
             link: :search_link,
             content: :description,
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

  def self.ordered_by_name_ignoring_prefix
    all.sort_by { |o| o.name_without_prefix }
  end

  def self.in_listing_order
    joins(:organisation_type).all.sort_by { |o| o.organisation_type.listing_order }
  end

  def agencies_and_public_bodies
    child_organisations.joins(:organisation_type).merge(OrganisationType.agency_or_public_body)
  end

  def agencies_and_public_bodies_by_type
    agencies_and_public_bodies.group_by(&:organisation_type).sort_by { |type,department| type.listing_order }
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
    name.gsub(/^Ministry of/, "").gsub(/^Department (of|for)/, "").gsub(/^Office of the/, "").strip
  end

  def display_name
    [acronym, name].find { |s| s.present? }
  end

  def search_link
    # This should be organisation_path(self), but we can't use that because friendly_id's #to_param returns
    # the old value of the slug (e.g. nil for a new record) if the record is dirty, and apparently the record
    # is still marked as dirty during after_save callbacks.
    organisation_path(slug)
  end

  def published_speeches
    ministerial_roles.map { |mr| mr.speeches.published }.flatten.uniq
  end

  def department?
    organisation_type.department?
  end

  def self.departments
    where(organisation_type_id: OrganisationType.departmental_types)
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

  def contact_and_contact_numbers_are_blank(attributes)
    attributes.all? { |key, value|
      key == '_destroy' ||
      value.blank? || (
        (key == "contact_numbers_attributes") &&
        value.all? { |contact_number_attributes|
          contact_number_attributes.all? { |contact_number_key, contact_number_value|
            contact_number_key == '_destroy' ||
            contact_number_value.blank?
          }
        }
      )
    }
  end

  def sub_organisations_must_have_a_parent
    if organisation_type && organisation_type.sub_organisation?
      if parent_organisations.empty?
        errors[:parent_organisations] << "must not be empty for sub-organisations"
      end
    end
  end
end
