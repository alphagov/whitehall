class Country < ActiveRecord::Base
  has_many :document_countries
  has_many :documents, through: :document_countries

  validates :name, presence: true
end