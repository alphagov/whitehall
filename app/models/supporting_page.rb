# == Schema Information
#
# Table name: supporting_pages
#
#  id           :integer          not null, primary key
#  edition_id   :integer
#  title        :string(255)
#  body         :text
#  created_at   :datetime
#  updated_at   :datetime
#  lock_version :integer          default(0)
#  slug         :string(255)
#

class SupportingPage < ActiveRecord::Base
  include Searchable
  include ::Attachable

  belongs_to :edition

  attachable :supporting_page

  validates_with SafeHtmlValidator
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

  def alternative_format_contact_email
    edition && edition.alternative_format_contact_email
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
    Whitehall.url_maker.public_supporting_page_path(edition, slug)
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
