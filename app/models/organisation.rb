class Organisation < ActiveRecord::Base
  has_many :document_organisations
  has_many :documents, through: :document_organisations
  has_many :published_documents, through: :document_organisations, class_name: "Document", conditions: { state: "published" }, source: :document

  has_many :organisation_roles
  has_many :roles, through: :organisation_roles
  has_many :ministerial_roles, through: :organisation_roles, source: :role
  has_many :people, through: :roles

  validates :name, presence: true, uniqueness: true
end