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

  after_commit :republish_index_pages_to_publishing_api

  enum world_location_type: { world_location: 1, international_delegation: 3 }

  accepts_nested_attributes_for :edition_world_locations

  include HasContentId

  include AnalyticsIdentifierPopulator
  self.analytics_prefix = "WL"

  include TranslatableModel
  translates :name

  scope :ordered_by_name, -> { with_translations(I18n.default_locale).order("world_location_translations.name") }

  def self.active
    where(active: true)
  end

  def display_type
    if international_delegation?
      I18n.t("world_location.type.international_delegation", count: 1)
    else
      I18n.t("world_location.type.world_location", count: 1)
    end
  end

  def display_type_key
    world_location_type
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
    ordered_by_name.in_order_of(:world_location_type, %w[world_location international_delegation]).group_by(&:world_location_type)
  end

  def self.countries
    where(world_location_type: "world_location").ordered_by_name
  end

  def self.geographical
    where(world_location_type: "world_location").ordered_by_name
  end

  validates_with SafeHtmlValidator
  validates :name, :world_location_type, presence: true

  def base_path
    "/world/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  extend FriendlyId
  friendly_id

  def republish_index_pages_to_publishing_api
    PresentPageToPublishingApi.new.publish(PublishingApi::EmbassiesIndexPresenter)
    PresentPageToPublishingApi.new.publish(PublishingApi::WorldIndexPresenter) if I18n.locale == :en
  end

  def publishing_api_presenter
    PublishingApi::WorldLocationPresenter
  end
end
