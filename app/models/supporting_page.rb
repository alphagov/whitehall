class SupportingPage < ActiveRecord::Base
  include Searchable
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  belongs_to :edition

  has_many :supporting_page_attachments
  has_many :attachments, through: :supporting_page_attachments

  accepts_nested_attributes_for :supporting_page_attachments, reject_if: :no_substantive_attachment_attributes?, allow_destroy: true

  def no_substantive_attachment_attributes?(attrs)
    attrs.fetch(:attachment_attributes, {}).except(:accessible).values.all?(&:blank?)
  end
  private :no_substantive_attachment_attributes?

  validates :title, :body, :edition, presence: true

  scope :published, joins(:edition).merge(Edition.published)

  searchable title: :title,
             link: :search_link,
             content: :body_without_markup,
             only: :published,
             index_after: false,
             unindex_after: false

  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :edition

  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def allows_attachments?
  end

  after_save do
    edition.touch
  end

  before_destroy :prevent_destruction_on_published_editions

  def destroyable?
    !edition.published?
  end

  def search_link
    # This should be public_supporting_page_path(edition, self), but we can't use that because friendly_id's
    # #to_param returns the old value of the slug (e.g. nil for a new record) if the record is dirty, and
    # apparently the record is still marked as dirty during after_save callbacks.
    public_supporting_page_path(edition, slug)
  end

  def body_without_markup
    Govspeak::Document.new(body).to_text
  end

  def document_title
    edition.title
  end

  def editable?
    edition.editable?
  end

  private

  def prevent_destruction_on_published_editions
    return false unless destroyable?
  end
end
