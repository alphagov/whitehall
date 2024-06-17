class TopicalEventFeaturing < ApplicationRecord
  belongs_to :edition, inverse_of: :topical_event_featurings
  belongs_to :offsite_link
  belongs_to :topical_event, inverse_of: :topical_event_featurings
  belongs_to :image, class_name: "TopicalEventFeaturingImageData", foreign_key: :topical_event_featuring_image_data_id

  accepts_nested_attributes_for :image, reject_if: :all_blank

  validate :image_is_present
  validates :alt_text, presence: true, allow_blank: true
  validates :alt_text, length: { maximum: 255 }

  validates :topical_event, :ordering, presence: true

  validates :edition_id, uniqueness: { scope: :topical_event_id }, unless: :offsite?

  after_save :republish_topical_event_to_publishing_api
  after_destroy :republish_topical_event_to_publishing_api

  def title
    if offsite?
      offsite_link.title
    else
      edition.title
    end
  end

  def summary
    if offsite?
      offsite_link.summary
    else
      edition.summary
    end
  end

  def url
    if offsite?
      offsite_link.url
    else
      edition.base_path
    end
  end

  def offsite?
    edition.nil?
  end

  def republish_topical_event_to_publishing_api
    Whitehall::PublishingApi.republish_async(topical_event)
  end

  def image_is_present
    errors.add(:"image.file", "can't be blank") if image.blank?
  end
end
