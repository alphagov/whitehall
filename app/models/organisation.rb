class Organisation < ActiveRecord::Base
  has_many :edition_organisations
  has_many :editions, through: :edition_organisations
  has_many :published_editions, through: :edition_organisations, class_name: "Edition", conditions: { state: "published" }, source: :edition
  has_many :published_policies, through: :edition_organisations, class_name: "Policy", conditions: { state: "published" }, source: :edition
  has_many :published_publications, through: :edition_organisations, class_name: "Publication", conditions: { state: "published" }, source: :edition

  has_many :roles
  has_many :people, through: :roles

  has_many :ministers

  validates :name, presence: true, uniqueness: true
end