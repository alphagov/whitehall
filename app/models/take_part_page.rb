class TakePartPage < ApplicationRecord
  include PublishesToPublishingApi
  include UserOrderable

  GET_INVOLVED_CONTENT_ID = "dbe329f1-359c-43f7-8944-580d4742aa91".freeze

  validates_with SafeHtmlValidator
  validates :title, :summary, presence: true, length: { maximum: 255 }
  validates :body, presence: true, length: { maximum: (16.megabytes - 1) }
  validates_with NoFootnotesInGovspeakValidator, attribute: :body

  before_save :ensure_ordering!
  scope :in_order, -> { order(:ordering) }

  extend FriendlyId
  friendly_id :title

  has_one :image, class_name: "FeaturedImageData", as: :featured_imageable, inverse_of: :featured_imageable
  accepts_nested_attributes_for :image, reject_if: :all_blank

  validate :image_is_present, on: :create
  validates :image_alt_text, presence: true, allow_blank: true, length: { maximum: 255 }, on: :create

  include Searchable
  searchable title: :title,
             link: :public_path,
             content: :body_without_markup,
             description: :summary,
             format: "take_part",
             ordering: :ordering

  def body_without_markup
    Govspeak::Document.new(body).to_text
  end

  def self.next_ordering
    (TakePartPage.maximum(:ordering) || 0) + 1
  end

  def base_path
    "/government/get-involved/take-part/#{slug}"
  end

  def public_path(options = {})
    append_url_options(base_path, options)
  end

  def public_url(options = {})
    Plek.website_root + public_path(options)
  end

  def publishing_api_presenter
    PublishingApi::TakePartPresenter
  end

  def self.patch_getinvolved_page_links
    pages = TakePartPage.in_order.map(&:content_id)

    Services.publishing_api.patch_links(
      GET_INVOLVED_CONTENT_ID,
      links: {
        take_part_pages: pages,
      },
    )
  end

protected

  def ensure_ordering!
    self.ordering = TakePartPage.next_ordering if ordering.nil?
  end

  def image_is_present
    errors.add(:"image.file", "can't be blank") if image.blank?
  end
end
