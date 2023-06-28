class TopicalEvent < ApplicationRecord
  include PublishesToPublishingApi
  include Searchable
  include SimpleWorkflow

  searchable title: :name,
             link: :search_link,
             content: :description,
             format: "topical_event",
             description: :description_without_markup,
             slug: :slug,
             start_date: :start_date,
             end_date: :end_date

  after_commit :republish_feature_organisations_to_publishing_api, if: :features?

  has_one :topical_event_about_page

  has_many :topical_event_memberships, inverse_of: :topical_event
  has_many :editions, through: :topical_event_memberships
  has_many :announcements, through: :topical_event_memberships
  has_many :consultations, through: :topical_event_memberships
  has_many :calls_for_evidence, through: :topical_event_memberships
  has_many :detailed_guides, through: :topical_event_memberships
  has_many :news_articles, through: :topical_event_memberships
  has_many :publications, through: :topical_event_memberships
  has_many :speeches, through: :topical_event_memberships

  has_many :features, inverse_of: :topical_event, dependent: :destroy
  has_many :offsite_links, as: :parent
  has_many :social_media_accounts, as: :socialable, dependent: :destroy

  has_many :topical_event_organisations
  has_many :organisations, through: :topical_event_organisations

  has_many :topical_event_featurings,
           lambda {
             where("editions.state = 'published' or topical_event_featurings.edition_id is null")
               .references(:edition)
               .includes(edition: :translations)
               .order("topical_event_featurings.ordering asc")
           },
           foreign_key: :topical_event_id,
           inverse_of: :topical_event

  has_many :featured_editions,
           -> { order("topical_event_featurings.ordering ASC") },
           through: :topical_event_featurings,
           source: :edition

  has_many :published_announcements,
           -> { where("editions.state" => "published") },
           through: :topical_event_memberships,
           class_name: "Announcement",
           source: :announcement

  has_many :published_publications,
           -> { where("editions.state" => "published") },
           through: :topical_event_memberships,
           class_name: "Publication",
           source: :publication

  has_many :published_consultations,
           -> { where("editions.state" => "published") },
           through: :topical_event_memberships,
           class_name: "Consultation",
           source: :consultation

  has_many :editions,
           -> { where("editions.state" => "published") },
           through: :topical_event_memberships

  scope :active, -> { where("end_date > ?", Time.zone.today) }
  scope :alphabetical, -> { order("name ASC") }
  scope :order_by_start_date, -> { order("start_date DESC") }
  scope :for_edition, ->(id) { joins(:topical_event_memberships).where(topical_event_memberships: { edition_id: id }) }

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :description

  validates :name, presence: true, uniqueness: { case_sensitive: false } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :description, presence: true
  validates :summary, presence: true
  validate :start_and_end_dates
  validates :start_date, presence: true, if: ->(topical_event) { topical_event.end_date }

  accepts_nested_attributes_for :topical_event_memberships
  accepts_nested_attributes_for :topical_event_organisations
  accepts_nested_attributes_for :topical_event_featurings
  accepts_nested_attributes_for :social_media_accounts, allow_destroy: true

  mount_uploader :logo, ImageUploader, mount_on: :carrierwave_image
  validates_with ImageValidator, method: :logo, mime_types: { "image/jpeg" => /(\.jpeg|\.jpg)$/, "image/png" => /\.png$/ }, if: :logo_changed?

  extend FriendlyId
  friendly_id

  alias_method :display_name, :to_s

  def archived?
    if end_date && end_date <= Time.zone.today
      true
    else
      false
    end
  end

  def search_link
    base_path
  end

  def self.grouped_by_type
    Rails.cache.fetch("filter_options/topics", expires_in: 30.minutes) do
      {
        "Topical events" => TopicalEvent.active.order_by_start_date.map { |o| [o.name, o.slug] },
      }
    end
  end

  def published_editions
    editions.published
  end

  def scheduled_editions
    editions.scheduled.order("scheduled_publication ASC")
  end

  def published_announcements
    published_editions.announcements
  end

  def published_consultations
    published_editions.consultations
  end

  def published_detailed_guides
    published_editions.detailed_guides
  end

  def published_non_statistics_publications
    published_editions.non_statistical_publications
  end

  def published_statistics_publications
    published_editions.statistical_publications
  end

  def lead_organisations
    organisations.where(topical_event_organisations: { lead: true }).reorder("topical_event_organisations.lead_ordering")
  end

  def lead_topical_event_organisations
    topical_event_organisations.where(lead: true).order("topical_event_organisations.lead_ordering")
  end

  def importance_ordered_organisations
    organisations.reorder("topical_event_organisations.lead DESC, topical_event_organisations.lead_ordering")
  end

  def latest(limit = 3)
    published_editions.in_reverse_chronological_order.includes(:translations).limit(limit)
  end

  def description_without_markup
    Govspeak::Document.new(description).to_text
  end

  def featured?(edition)
    return false unless edition.persisted?

    featuring_of(edition).present?
  end

  def featuring_of(edition)
    topical_event_featurings.detect { |cf| cf.edition == edition }
  end

  def feature(featuring_params)
    topical_event_featurings.create({ ordering: next_ordering }.merge(featuring_params.to_h))
  end

  def next_ordering
    last = topical_event_featurings.maximum(:ordering)
    last ? last + 1 : 0
  end

  def to_s
    name
  end

  def base_path
    "/government/topical-events/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  def featurable_offsite_links
    offsite_links.reject do |link|
      topical_event_featurings.detect do |featuring|
        featuring.offsite_link == link
      end
    end
  end

  def featurable_editions
    editions.reject do |edition|
      topical_event_featurings.detect do |featuring|
        featuring.edition == edition
      end
    end
  end

private

  delegate :any?, to: :features
  alias_method :features?, :any?

  def republish_feature_organisations_to_publishing_api
    features.map(&:republish_featurable_to_publishing_api)
  end

  def start_and_end_dates
    if start_date && end_date
      if more_than_a_year(start_date, end_date)
        errors.add(:base, "cannot be longer than a year")
      end
      if start_date >= end_date
        errors.add(:end_date, "cannot be before or equal to the start_date")
      end
    end
  end

  def more_than_a_year(from_time, to_time = 0)
    to_time > from_time + 1.year + 1.day # allow 1 day's leeway
  end

  def logo_changed?
    changes["carrierwave_image"].present?
  end
end
