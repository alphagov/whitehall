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

  has_one :world_location_news
  accepts_nested_attributes_for :world_location_news
  delegate :title, to: :world_location_news

  accepts_nested_attributes_for :edition_world_locations

  include AnalyticsIdentifierPopulator
  self.analytics_prefix = "WL"

  include TranslatableModel
  translates :name

  include Searchable
  searchable title: :title,
             link: :search_link,
             description: :search_description,
             only: :active_international_delegation,
             format: "world_location",
             slug: :slug
  include PublishesToPublishingApi

  def publish_to_publishing_api
    # WorldLocations no longer support translations
    # but the current world news pages use the world location object
    # to build their featured articles lists so we need to keep
    # the translations but not publish them.
    run_callbacks :published do
      PublishingApiWorker.perform_async(
        self.class.name,
        id,
        nil,
        "en",
      )
    end
  end

  def search_link
    Whitehall.url_maker.world_location_path(slug)
  end

  def search_description
    if world_location_type == WorldLocationType::InternationalDelegation
      I18n.t("world_location.search_description.international_delegation", name:)
    else
      I18n.t("world_location.search_description.world_location", name:)
    end
  end

  after_update :remove_from_index_if_became_inactive
  def remove_from_index_if_became_inactive
    remove_from_search_index if saved_change_to_active? && !active
  end

  scope :ordered_by_name, -> { with_translations(I18n.default_locale).order("world_location_translations.name") }

  def self.active
    where(active: true)
  end

  def self.active_international_delegation
    where(active: true, world_location_type_id: WorldLocationType::InternationalDelegation.id)
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
    ordered_by_name.group_by(&:world_location_type).sort_by { |type, _location| type.sort_order }
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
end
