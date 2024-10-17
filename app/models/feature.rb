class Feature < ApplicationRecord
  belongs_to :document
  belongs_to :topical_event
  belongs_to :offsite_link
  belongs_to :feature_list

  has_one :image, class_name: "FeaturedImageData", as: :featured_imageable, inverse_of: :featured_imageable
  accepts_nested_attributes_for :image, reject_if: :all_blank

  validates :document, presence: true, unless: ->(feature) { feature.topical_event_id.present? || feature.offsite_link_id.present? }
  validates :started_at, presence: true
  validate :image_is_present
  validates :alt_text, length: { maximum: 255 }

  before_validation :set_started_at!, on: :create

  delegate :republish_featurable_to_publishing_api, to: :feature_list

  def to_s
    if document && document.live_edition
      LocalisedModel.new(document.live_edition, locale).title
    elsif topical_event
      topical_event.name
    elsif offsite_link
      offsite_link.title
    else
      "Feature #{id}"
    end
  end

  def self.current
    where(ended_at: nil)
  end

  def self.with_published_edition
    joins(document: :live_edition)
  end

  def self.with_topical_events
    joins(:topical_event)
  end

  def end!
    self.ended_at = Time.zone.now
    save!(validate: false)
  end

  def locale
    feature_list ? feature_list.locale : :en
  end

  def republish_to_publishing_api_async
    republish_featurable_to_publishing_api
    if document&.editions&.select { |edition| edition.is_a?(Speech) }.present?
      Whitehall::PublishingApi.republish_document_async(document)
    end
  end

private

  def set_started_at!
    self.started_at = Time.zone.now
  end

  def image_is_present
    errors.add(:"image.file", "can't be blank") if image.blank?
  end
end
