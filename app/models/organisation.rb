class Organisation < ActiveRecord::Base
  has_many :document_organisations
  has_many :documents, through: :document_organisations
  has_many :published_documents, through: :document_organisations, class_name: "Document", conditions: { state: "published" }, source: :document

  has_many :organisation_roles
  has_many :roles, through: :organisation_roles
  has_many :ministerial_roles, class_name: 'MinisterialRole', through: :organisation_roles, source: :role
  has_many :board_member_roles, class_name: 'BoardMemberRole', through: :organisation_roles, source: :role
  has_many :leading_board_member_roles, class_name: 'BoardMemberRole', through: :organisation_roles, source: :role, conditions: { leader: true }
  has_many :other_board_member_roles, class_name: 'BoardMemberRole', through: :organisation_roles, source: :role, conditions: { leader: false }

  has_many :people, through: :roles

  has_many :phone_numbers
  accepts_nested_attributes_for :phone_numbers, reject_if: :all_blank

  validates :name, presence: true, uniqueness: true

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end
end