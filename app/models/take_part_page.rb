class TakePartPage < ActiveRecord::Base

  validates_with SafeHtmlValidator
  validates :title, :summary, presence: true, length: { maximum: 255 }
  # default tokenizer does value.split(//) which takes forever on large strings
  # and serves no purpose whatsoever on ruby > 1.9 - rails 3.2+ don't 
  # tokenize strings by default so it's safe to remove
  validates :body, presence: true, length: { maximum: (16.megabytes - 1), tokenizer: ->(value) {value} }

  before_save :ensure_ordering!
  scope :in_order, -> { order(:ordering) }

  extend FriendlyId
  friendly_id :title

  validates :image, presence: true, on: :create
  validates :image_alt_text, presence: true, length: { maximum: 255 }, on: :create
  validate :image_must_be_960px_by_640px, if: :image_changed?

  mount_uploader :image, ImageUploader, mount_on: :carrierwave_image

  def self.next_ordering
    (TakePartPage.maximum(:ordering) || 0) + 1
  end

  protected
  def image_must_be_960px_by_640px
    if image.path
      errors.add(:image, 'must be 960px wide and 640px tall') unless ImageSizeChecker.new(image.path).size_is?(960, 640)
    end
  end

  def image_changed?
    changes["carrierwave_image"].present?
  end

  def ensure_ordering!
    self.ordering = TakePartPage.next_ordering if self.ordering.nil?
  end

end
