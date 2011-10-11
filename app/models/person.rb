class Person < ActiveRecord::Base
  has_many :roles
  has_many :organisation_roles, through: :roles
  has_many :organisations, through: :organisation_roles

  validates :name, presence: true
end