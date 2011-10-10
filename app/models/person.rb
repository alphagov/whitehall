class Person < ActiveRecord::Base
  has_many :roles
  has_many :organisations, through: :roles

  validates :name, presence: true
end