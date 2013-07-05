class TakePartPage < ActiveRecord::Base

  validates_with SafeHtmlValidator
  validates :title, :summary, presence: true, length: { maximum: 255 }
  validates :body, presence: true, length: { maximum: (16.megabytes - 1) }

  before_save :ensure_ordering!
  scope :in_order, -> { order(:ordering) }

  extend FriendlyId
  friendly_id :title

  validates :image, presence: true, on: :create
  validates :image_alt_text, presence: true, length: { maximum: 255 }, on: :create
  validate :image_must_be_960px_by_640px, if: :image_changed?

  mount_uploader :image, ImageUploader, mount_on: :carrierwave_image

  include Searchable
  searchable title: :title,
             link: :search_link,
             content: :body_without_markup,
             description: :summary,
             format: 'take_part'

  def search_link
    Whitehall.url_maker.take_part_page_path(self.slug)
  end

  def body_without_markup
    Govspeak::Document.new(body).to_text
  end

  def self.next_ordering
    (TakePartPage.maximum(:ordering) || 0) + 1
  end

  def self.reorder!(ids_in_new_ordering)
    return if ids_in_new_ordering.empty?
    ids_in_new_ordering = ids_in_new_ordering.map(&:to_s)
    TakePartPage.transaction do
      TakePartPage.where(id: ids_in_new_ordering).each do |page|
        page.update_column(:ordering, ids_in_new_ordering.index(page.id.to_s) + 1)
      end
      TakePartPage.where('id NOT IN (?)', ids_in_new_ordering).update_all(ordering: ids_in_new_ordering.size + 1)
    end
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
