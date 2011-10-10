class Person < ActiveRecord::Base
  has_many :roles
  has_many :organisations, through: :roles

  validates_presence_of :name
end