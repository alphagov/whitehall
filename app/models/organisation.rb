class Organisation < ActiveRecord::Base
  has_many :document_organisations
  has_many :documents, through: :document_organisations
  has_many :published_documents, through: :document_organisations, class_name: "Document", conditions: { state: "published" }, source: :document

  has_many :organisation_ministerial_roles
  has_many :ministerial_roles, through: :organisation_ministerial_roles
  has_many :people, through: :ministerial_roles

  validates :name, presence: true, uniqueness: true
end