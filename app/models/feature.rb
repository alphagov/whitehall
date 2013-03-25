class Feature < ActiveRecord::Base
  belongs_to :document
  belongs_to :feature_list

  mount_uploader :image, ImageUploader, mount_on: :carrierwave_image
  validates :document, :image, :started_at, presence: true

  validate :image_must_be_960px_by_640px, if: :image_changed?

  before_validation :set_started_at!, on: :create

  def to_s
    if document && document.published_edition
      LocalisedModel.new(document.published_edition, locale).title
    end
  end

  def self.current
    where(ended_at: nil)
  end

  def self.with_published_edition
    joins(document: :published_edition)
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

  def image_must_be_960px_by_640px
    if image.path
      errors.add(:image, 'must be 960px wide and 640px tall') unless ImageSizeChecker.new(image.path).size_is?(960, 640)
    end
  end
end
