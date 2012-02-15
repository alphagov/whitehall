class Country < ActiveRecord::Base
  FEATURED_COUNTRY_NAMES = ["Spain", "USA", "Uganda"]

  has_many :document_countries
  has_many :documents, through: :document_countries

  validates :name, presence: true

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def featured?
    FEATURED_COUNTRY_NAMES.include?(name)
  end
end
