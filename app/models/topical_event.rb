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

  has_many :classification_memberships, inverse_of: :topical_event
  has_many :editions, through: :classification_memberships
  has_many :announcements, through: :classification_memberships
  has_many :consultations, through: :classification_memberships
  has_many :detailed_guides, through: :classification_memberships
  has_many :news_articles, through: :classification_memberships
  has_many :publications, through: :classification_memberships
  has_many :speeches, through: :classification_memberships

  has_many :features, inverse_of: :topical_event, dependent: :destroy
  has_many :offsite_links, as: :parent
  has_many :social_media_accounts, as: :socialable, dependent: :destroy

  has_many :organisation_classifications
  has_many :organisations, through: :organisation_classifications

  has_many :classification_featurings,
           lambda {
             where("editions.state = 'published' or classification_featurings.edition_id is null")
               .references(:edition)
               .includes(edition: :translations)
               .order("classification_featurings.ordering asc")
           },
           foreign_key: :topical_event_id,
           inverse_of: :topical_event

  has_many :featured_editions,
           -> { order("classification_featurings.ordering ASC") },
           through: :classification_featurings,
           source: :edition

  has_many :published_announcements,
           -> { where("editions.state" => "published") },
           through: :classification_memberships,
           class_name: "Announcement",
           source: :announcement

  has_many :published_publications,
           -> { where("editions.state" => "published") },
           through: :classification_memberships,
           class_name: "Publication",
           source: :publication

  has_many :published_consultations,
           -> { where("editions.state" => "published") },
           through: :classification_memberships,
           class_name: "Consultation",
           source: :consultation

  has_many :editions,
           -> { where("editions.state" => "published") },
           through: :classification_memberships

  scope :active, -> { where("end_date > ?", Time.zone.today) }
  scope :alphabetical, -> { order("name ASC") }
  scope :order_by_start_date, -> { order("start_date DESC") }
  scope :for_edition, ->(id) { joins(:classification_memberships).where(classification_memberships: { edition_id: id }) }

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :description

  validates :name, presence: true, uniqueness: { case_sensitive: false } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :description, presence: true
  validate :start_and_end_dates
  validates :start_date, presence: true, if: ->(topical_event) { topical_event.end_date }

  accepts_nested_attributes_for :classification_memberships
  accepts_nested_attributes_for :organisation_classifications
  accepts_nested_attributes_for :classification_featurings
  accepts_nested_attributes_for :social_media_accounts, allow_destroy: true

  mount_uploader :logo, ImageUploader, mount_on: :carrierwave_image

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

  def base_path
    Whitehall.url_maker.topical_event_path(slug)
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
    organisations.where(organisation_classifications: { lead: true }).reorder("organisation_classifications.lead_ordering")
  end

  def lead_organisation_classifications
    organisation_classifications.where(lead: true).order("organisation_classifications.lead_ordering")
  end

  def importance_ordered_organisations
    organisations.reorder("organisation_classifications.lead DESC, organisation_classifications.lead_ordering")
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
    classification_featurings.detect { |cf| cf.edition == edition }
  end

  def feature(featuring_params)
    classification_featurings.create({ ordering: next_ordering }.merge(featuring_params.to_h))
  end

  def next_ordering
    last = classification_featurings.maximum(:ordering)
    last ? last + 1 : 0
  end

  def to_s
    name
  end

private

  delegate :any?, to: :features
  alias_method :features?, :any?

  def republish_feature_organisations_to_publishing_api
    features.map(&:republish_organisation_to_publishing_api)
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
