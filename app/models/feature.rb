class Feature < ActiveRecord::Base
  belongs_to :document
  belongs_to :topical_event
  belongs_to :feature_list

  mount_uploader :image, ImageUploader, mount_on: :carrierwave_image
  validates :document, presence: true, unless: -> feature { feature.topical_event_id.present? }
  validates :started_at, presence: true
  validates :image, presence: true, on: :create
  validates_with ImageValidator, method: :image, size: [960, 640], if: :image_changed?

  before_validation :set_started_at!, on: :create

  def to_s
    if document && document.published_edition
      LocalisedModel.new(document.published_edition, locale).title
    elsif topical_event
      topical_event.name
    else
      "Feature #{id}"
    end
  end

  def self.current
    where(ended_at: nil)
  end

  def self.with_published_edition
    joins(document: :published_edition)
  end

  def self.with_topical_events
    joins(:topical_event)
  end

  def end!
    self.ended_at = Time.zone.now
    save
  end

  def locale
    feature_list ? feature_list.locale : :en
  end

  private

  def set_started_at!
    self.started_at = Time.zone.now
  end

  def image_changed?
    changes["carrierwave_image"].present?
  end
end
