class Country < ActiveRecord::Base
  FEATURED_COUNTRY_NAMES = ["Spain", "USA", "Uganda"]

  FEATURED_COUNTRY_URLS = {
    "Spain"  => ["http://ukinspain.fco.gov.uk"],
    "Uganda" => ["http://ukinuganda.fco.gov.uk", "http://www.dfid.gov.uk/Uganda"],
    "USA"    => ["http://ukinusa.fco.gov.uk"],
  }

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

  def self.featured
    where(name: FEATURED_COUNTRY_NAMES)
  end

  def urls
    FEATURED_COUNTRY_URLS[name] || []
  end
end
