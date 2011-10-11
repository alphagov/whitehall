class Person < ActiveRecord::Base
  has_many :ministerial_roles
  has_many :organisation_ministerial_roles, through: :ministerial_roles
  has_many :organisations, through: :organisation_ministerial_roles

  validates :name, presence: true
end