class Country < ActiveRecord::Base
  validates :name, presence: true
end