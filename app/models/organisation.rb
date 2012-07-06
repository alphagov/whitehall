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
            order: "published_at DESC",
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

  has_many :organisation_roles
  has_many :roles, through: :organisation_roles
  has_many :ministerial_roles,
            class_name: 'MinisterialRole',
            through: :organisation_roles,
            source: :role
  has_many :board_member_roles,
            class_name: 'BoardMemberRole',
            through: :organisation_roles,
            source: :role
  has_many :military_roles,
            class_name: 'MilitaryRole',
            through: :organisation_roles,
            source: :role
  has_many :permanent_secretary_board_member_roles,
            class_name: 'BoardMemberRole',
            through: :organisation_roles,
            source: :role,
            conditions: { permanent_secretary: true }
  has_many :other_board_member_roles,
            class_name: 'BoardMemberRole',
            through: :organisation_roles,
            source: :role,
            conditions: { permanent_secretary: false }

  has_many :people, through: :roles

  has_many :organisation_topics, dependent: :destroy
  has_many :topics, through: :organisation_topics

  has_many :users, dependent: :nullify

  has_many :contacts, dependent: :destroy
  has_many :social_media_accounts, dependent: :destroy

  accepts_nested_attributes_for :contacts, reject_if: :contact_and_contact_numbers_are_blank
  accepts_nested_attributes_for :social_media_accounts, allow_destroy: true
  accepts_nested_attributes_for :organisation_roles
  accepts_nested_attributes_for :edition_organisations

  validates :name, presence: true, uniqueness: true
  validates :organisation_type_id, presence: true
  validates :logo_formatted_name, presence: true

  default_scope order(:name)

  searchable title: :name,
             link: :search_link,
             content: :description,
             boost_phrases: :acronym

  extend FriendlyId
  friendly_id :name, use: :slugged

  before_destroy { |r| r.destroyable? }

  def should_generate_new_friendly_id?
    new_record?
  end

  def self.ordered_by_name_ignoring_prefix
    all.sort_by { |o| o.name_without_prefix }
  end

  def self.in_listing_order
    joins(:organisation_type).all.sort_by { |o| o.organisation_type.listing_order }
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

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def search_link
    # This should be organisation_path(self), but we can't use that because friendly_id's #to_param returns
    # the old value of the slug (e.g. nil for a new record) if the record is dirty, and apparently the record
    # is still marked as dirty during after_save callbacks.
    organisation_path(slug)
  end

  def top_ministerial_role
    ministerial_roles.order(:ordering).first
  end

  def top_civil_servant
    board_member_roles.where(permanent_secretary: true).first
  end

  def top_military_role
    military_roles.where(chief_of_the_defence_staff: true).first
  end

  def published_speeches
    ministerial_roles.map { |mr| mr.speeches.published }.flatten.uniq
  end

  def calculate_active?
    !!(organisation_type && organisation_type.department?)
  end

  def update_cached_active_state!
    new_active_state = calculate_active?
    if new_active_state != active?
      update_column :active, calculate_active?
    end
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

  def root_organisation
    path = []
    current = self
    while current && ! path.include?(current)
      path << current
      current = current.parent_organisations.first
    end
    path.last
  end

  def destroyable?
    child_organisations.none? && organisation_roles.none? && !new_record?
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
end
