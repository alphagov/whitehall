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

  validates :title, presence: true

  def search_description
    I18n.t("world_news.uk_updates_in_country", country: name)
  end

  def self.active
    includes(:world_location).references(:world_locations).where("world_locations.active = ?", true)
  end

  def search_link
    if world_location.world_location?
      public_path
    elsif world_location.international_delegation?
      world_location.public_path
    end
  end

  def contacts
    return [] unless world_location.international_delegation?

    world_location
      .worldwide_organisations
      .filter_map(&:main_office)
      .map(&:contact)
      .flatten
  end

  def organisations
    return [] unless world_location.international_delegation?

    world_location
      .worldwide_organisations
      .map(&:sponsoring_organisations)
      .flatten
  end

  def worldwide_organisations
    return [] unless world_location.international_delegation?

    world_location
      .worldwide_organisations
  end

  def base_path
    "/world/#{slug}/news"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  extend FriendlyId
  friendly_id

  def publishing_api_presenter
    PublishingApi::WorldLocationNewsPresenter
  end
end
