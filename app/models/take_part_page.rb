class TakePartPage < ApplicationRecord
  validates_with SafeHtmlValidator
  validates :title, :summary, presence: true, length: { maximum: 255 }
  validates :body, presence: true, length: { maximum: (16.megabytes - 1) }
  validates_with NoFootnotesInGovspeakValidator, attribute: :body

  before_save :ensure_ordering!
  after_commit :patch_getinvolved_page_links
  scope :in_order, -> { order(:ordering) }

  extend FriendlyId
  friendly_id :title

  include PublishesToPublishingApi

  mount_uploader :image, ImageUploader, mount_on: :carrierwave_image

  validates :image, presence: true, on: :create
  validates :image_alt_text, presence: true, allow_blank: true, length: { maximum: 255 }, on: :create
  validates_with ImageValidator, method: :image, size: [960, 640], if: :image_changed?

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

  def self.reorder!(ids_in_new_ordering)
    return if ids_in_new_ordering.empty?

    ids_in_new_ordering = ids_in_new_ordering.map(&:to_s)
    TakePartPage.transaction do
      TakePartPage.where(id: ids_in_new_ordering).find_each do |page|
        page.update(ordering: ids_in_new_ordering.index(page.id.to_s) + 1)
      end
      TakePartPage.where("id NOT IN (?)", ids_in_new_ordering).update_all(ordering: ids_in_new_ordering.size + 1)
    end
  end

  def base_path
    "/government/get-involved/take-part/#{slug}"
  end

  def public_path(options = {}, locale:)
    append_url_options(base_path, options, locale:)
  end

  def public_url(options = {}, locale:)
    Plek.website_root + public_path(options, locale:)
  end

protected

  def image_changed?
    changes["carrierwave_image"].present?
  end

  def ensure_ordering!
    self.ordering = TakePartPage.next_ordering if ordering.nil?
  end

  def patch_getinvolved_page_links
    get_involved_content_id = "dbe329f1-359c-43f7-8944-580d4742aa91"
    pages = TakePartPage.in_order.map(&:content_id)

    Services.publishing_api.patch_links(
      get_involved_content_id,
      links: {
        take_part_pages: pages,
      },
    )
  end
end
