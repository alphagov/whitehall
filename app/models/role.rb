class Role < ActiveRecord::Base
  has_many :organisation_roles
  has_many :organisations, through: :organisation_roles
  belongs_to :person

  validates :name, presence: true
end