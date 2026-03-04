# LEGACY TOPICAL EVENTS ONLY
class TopicalEvent < ApplicationRecord
  include PublishesToPublishingApi

  has_one :topical_event_about_page

  has_many :topical_event_memberships, inverse_of: :topical_event
  has_many :editions, through: :topical_event_memberships

  MAX_FEATURED_DOCUMENTS = 6
  has_many :offsite_link_parents, as: :parent
  has_many :offsite_links, through: :offsite_link_parents

  has_many :topical_event_organisations, -> { extending UserOrderableExtension }
  has_many :organisations, through: :topical_event_organisations

  has_many :topical_event_featurings,
           lambda {
             (extending UserOrderableExtension)
              .where("editions.state = 'published' or topical_event_featurings.edition_id is null")
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

  has_many :editions,
           -> { where("editions.state" => "published") },
           through: :topical_event_memberships

  has_one :logo, class_name: "FeaturedImageData", as: :featured_imageable, inverse_of: :featured_imageable

  accepts_nested_attributes_for :logo, reject_if: :all_blank

  scope :active, -> { where("1=1") } # Temporary change - treat all topical events as active.

  accepts_nested_attributes_for :topical_event_memberships
  accepts_nested_attributes_for :topical_event_organisations
  accepts_nested_attributes_for :topical_event_featurings

  extend FriendlyId
  friendly_id

  alias_method :display_name, :to_s

  def lead_organisations
    organisations.where(topical_event_organisations: { lead: true }).reorder("topical_event_organisations.lead_ordering")
  end

  def lead_topical_event_organisations
    topical_event_organisations.where(lead: true).order("topical_event_organisations.lead_ordering")
  end

  def latest(limit = 3)
    editions.published.in_reverse_chronological_order.includes(:translations).limit(limit)
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

  def featurable_editions(editions)
    editions.reject do |edition|
      topical_event_featurings.detect do |featuring|
        featuring.edition == edition
      end
    end
  end

  def publishing_api_presenter
    PublishingApi::TopicalEventPresenter
  end
end
