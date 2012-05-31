class Country < ActiveRecord::Base
  FEATURED_COUNTRY_NAMES = ["Spain"]

  FEATURED_COUNTRY_URLS = {
    "Spain"  => ["http://ukinspain.fco.gov.uk"]
  }

  has_many :edition_countries
  has_many :editions, through: :edition_countries
  has_many :featured_news_articles, through: :edition_countries, class_name: "NewsArticle", source: :edition, conditions: { "edition_countries.featured" => true, "editions.state" => "published" }

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
