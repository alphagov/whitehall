class WorldLocation < ApplicationRecord
  has_many :edition_world_locations, inverse_of: :world_location
  has_many :editions,
            through: :edition_world_locations
  has_many :published_edition_world_locations,
           -> { where(editions: { state: "published" }).includes(:edition) },
           class_name: "EditionWorldLocation"
  has_many :published_editions,
            through: :published_edition_world_locations,
            source: :edition
  has_many :published_documents,
            through: :published_editions,
            source: :document
  has_many :worldwide_organisation_world_locations, dependent: :destroy
  has_many :worldwide_organisations, through: :worldwide_organisation_world_locations
  has_many :offsite_links, as: :parent

  has_many :featured_links, -> { order(:created_at) }, as: :linkable, dependent: :destroy
  accepts_nested_attributes_for :featured_links, reject_if: -> attributes { attributes['url'].blank? }, allow_destroy: true

  include Featurable

  accepts_nested_attributes_for :edition_world_locations
  accepts_nested_attributes_for :offsite_links

  after_update :send_news_page_to_publishing_api_and_rummager

  include AnalyticsIdentifierPopulator
  self.analytics_prefix = 'WL'

  include TranslatableModel
  translates :name, :title, :mission_statement

  include Searchable
  searchable title: :name,
             link: :search_link,
             content: :mission_statement,
             only: :active,
             format: 'world_location',
             slug: :slug
  include PublishesToPublishingApi

  def search_link
    Whitehall.url_maker.world_location_path(slug)
  end

  after_update :remove_from_index_if_became_inactive
  def remove_from_index_if_became_inactive
    remove_from_search_index if self.active_changed? && !self.active
  end

  scope :ordered_by_name, ->() { with_translations(I18n.default_locale).order('world_location_translations.name') }

  def self.active
    where(active: true)
  end

  def self.with_announcements
    announcement_conditions = Edition.joins(:edition_world_locations).
                                            published.
                                            where(type: Announcement.sti_names).
                                            where("edition_world_locations.world_location_id = world_locations.id").
                                            select('*').to_sql

    where("exists (#{announcement_conditions})")
  end

  def self.with_publications
    publication_conditions = Edition.joins(:edition_world_locations).
                                            published.
                                            where(type: Publicationesque.sti_names).
                                            where("edition_world_locations.world_location_id = world_locations.id").
                                            select('*').to_sql

    where("exists (#{publication_conditions})")
  end

  def world_location_type
    WorldLocationType.find_by_id(world_location_type_id)
  end

  def world_location_type=(new_world_location_type)
    self.world_location_type_id = new_world_location_type && new_world_location_type.id
  end

  def display_type
    world_location_type.name
  end

  def display_type_key
    world_location_type.key
  end

  def name_without_prefix
    name.gsub(/^The/, "").strip
  end

  def worldwide_organisations_with_sponsoring_organisations
    (worldwide_organisations + worldwide_organisations.map { |o| o.sponsoring_organisations.to_a }.flatten).uniq
  end

  def to_s
    name
  end

  def self.all_by_type
    ordered_by_name.group_by(&:world_location_type).sort_by { |type, location| type.sort_order }
  end

  def self.countries
    where(world_location_type_id: WorldLocationType::WorldLocation.id).ordered_by_name
  end

  def self.geographical
    where(world_location_type_id: WorldLocationType.geographic.map(&:id)).ordered_by_name
  end

  validates_with SafeHtmlValidator
  validates :name, :world_location_type_id, presence: true

  extend FriendlyId
  friendly_id

  def send_news_page_to_publishing_api_and_rummager
    WorldLocationNewsPageWorker.new.perform(id)
  end
end
