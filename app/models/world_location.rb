class WorldLocation < ActiveRecord::Base
  FEATURED_WORLD_LOCATION_NAMES = ["Spain"]

  FEATURED_WORLD_LOCATION_URLS = {
    "Spain"  => ["http://ukinspain.fco.gov.uk"]
  }

  has_many :edition_world_locations
  has_many :editions,
            through: :edition_world_locations
  has_many :published_editions,
            through: :edition_world_locations,
            class_name: "Edition",
            conditions: { state: "published" },
            source: :edition
  has_many :featured_news_articles,
            through: :edition_world_locations,
            class_name: "NewsArticle",
            source: :edition,
            conditions: { "edition_world_locations.featured" => true,
                          "editions.state" => "published" }

  def world_location_type
    WorldLocationType.find_by_id(world_location_type_id)
  end

  def world_location_type=(new_world_location_type)
    self.world_location_type_id = new_world_location_type && new_world_location_type.id
  end

  def display_type
    world_location_type.name
  end

  validates_with SafeHtmlValidator
  validates :name, :world_location_type_id, presence: true

  extend FriendlyId
  friendly_id

  def featured?
    FEATURED_WORLD_LOCATION_NAMES.include?(name)
  end

  def self.featured
    where(name: FEATURED_WORLD_LOCATION_NAMES)
  end

  def urls
    FEATURED_WORLD_LOCATION_URLS[name] || []
  end
end
