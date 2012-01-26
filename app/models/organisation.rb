class Organisation < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :organisation_type

  has_many :child_organisational_relationships, foreign_key: :parent_organisation_id, class_name: "OrganisationalRelationship"
  has_many :parent_organisational_relationships, foreign_key: :child_organisation_id, class_name: "OrganisationalRelationship"
  has_many :child_organisations, through: :child_organisational_relationships
  has_many :parent_organisations, through: :parent_organisational_relationships

  has_many :document_organisations
  has_many :documents, through: :document_organisations
  has_many :published_documents, through: :document_organisations, class_name: "Document", conditions: { state: "published" }, source: :document
  has_many :corporate_publications, through: :document_organisations, class_name: "Publication", conditions: {"documents.corporate_publication" => true}, source: :document
  has_many :featured_news_articles, through: :document_organisations, class_name: "NewsArticle", conditions: { "document_organisations.featured" => true, "documents.state" => "published" }, source: :document

  has_many :organisation_roles
  has_many :roles, through: :organisation_roles
  has_many :ministerial_roles, class_name: 'MinisterialRole', through: :organisation_roles, source: :role
  has_many :board_member_roles, class_name: 'BoardMemberRole', through: :organisation_roles, source: :role
  has_many :permanent_secretary_board_member_roles, class_name: 'BoardMemberRole', through: :organisation_roles, source: :role, conditions: { permanent_secretary: true }
  has_many :other_board_member_roles, class_name: 'BoardMemberRole', through: :organisation_roles, source: :role, conditions: { permanent_secretary: false }

  has_many :people, through: :roles

  has_many :organisation_policy_areas
  has_many :policy_areas, through: :organisation_policy_areas

  has_many :phone_numbers
  accepts_nested_attributes_for :phone_numbers, reject_if: :all_blank

  validates :name, presence: true, uniqueness: true
  validates :organisation_type_id, presence: true

  default_scope order(:name)

  extend FriendlyId
  friendly_id :name, use: :slugged

  after_save :update_in_search_index
  after_destroy :remove_from_search_index

  def should_generate_new_friendly_id?
    new_record?
  end

  def self.ordered_by_name_ignoring_prefix
    all.sort_by { |o| o.name_without_prefix }
  end

  def self.in_listing_order
    joins(:organisation_type).all.sort_by { |o| o.organisation_type.listing_order }
  end

  def name_without_prefix
    name.gsub(/^Ministry of/, "").gsub(/^Department (of|for)/, "").gsub(/^Office of the/, "").strip
  end

  def display_name
    acronym || name
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def search_index
    # This should be organisation_path(self), but we can't use that because friendly_id's #to_param returns
    # the old value of the slug (e.g. nil for a new record) if the record is dirty, and apparently the record
    # is still marked as dirty during after_save callbacks.
    link = organisation_path(slug)

    { 'title' => name, 'link' => link, 'indexable_content' => description, 'format' => 'organisation' }
  end

  private

  def update_in_search_index
    Rummageable.index(search_index)
  end

  def remove_from_search_index
    Rummageable.delete(organisation_path(self))
  end
end