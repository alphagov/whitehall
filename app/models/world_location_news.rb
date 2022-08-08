class WorldLocationNews < ApplicationRecord
  FEATURED_DOCUMENTS_DISPLAY_LIMIT = 5

  belongs_to :world_location
  accepts_nested_attributes_for :world_location

  validates_with SafeHtmlValidator

  delegate :analytics_identifier, to: :world_location
  delegate :name, to: :world_location
  delegate :slug, :slug=, to: :world_location

  has_many :featured_links, -> { order(:created_at) }, as: :linkable, dependent: :destroy
  accepts_nested_attributes_for :featured_links, reject_if: ->(attributes) { attributes["url"].blank? }, allow_destroy: true
  has_many :offsite_links, as: :parent
  accepts_nested_attributes_for :offsite_links

  include Featurable

  include TranslatableModel
  translates :title, :mission_statement

  include PublishesToPublishingApi

  include Searchable
  searchable title: :title,
             link: :search_link,
             format: "world_location_news",
             description: :search_description,
             only: :active,
             indexable_content: :search_description

  def search_description
    I18n.t("world_news.uk_updates_in_country", country: name)
  end

  def self.active
    includes(:world_location).references(:world_locations).where("world_locations.active = ?", true)
  end

  def search_link
    Whitehall.url_maker.world_location_news_index_path(world_location)
  end

  extend FriendlyId
  friendly_id
end
