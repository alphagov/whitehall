class Organisation < ActiveRecord::Base
  belongs_to :organisation_type

  has_many :child_organisational_relationships, foreign_key: :parent_organisation_id, class_name: "OrganisationalRelationship"
  has_many :parent_organisational_relationships, foreign_key: :child_organisation_id, class_name: "OrganisationalRelationship"
  has_many :child_organisations, through: :child_organisational_relationships
  has_many :parent_organisations, through: :parent_organisational_relationships

  has_many :document_organisations
  has_many :documents, through: :document_organisations
  has_many :published_documents, through: :document_organisations, class_name: "Document", conditions: { state: "published" }, source: :document
  has_many :corporate_publications, through: :document_organisations, class_name: "Publication", conditions: {"documents.corporate_publication" => true}, source: :document

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

  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end
end