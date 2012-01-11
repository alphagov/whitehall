class SupportingPage < ActiveRecord::Base
  belongs_to :document

  has_many :supporting_page_attachments
  has_many :attachments, through: :supporting_page_attachments

  accepts_nested_attributes_for :supporting_page_attachments, allow_destroy: true
  accepts_nested_attributes_for :attachments, reject_if: :all_blank

  validates :title, :body, :document, presence: true

  extend FriendlyId
  friendly_id :title, use: :slugged

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
    document.touch
  end

  before_destroy :prevent_destruction_on_published_documents

  def destroyable?
    !document.published?
  end

  private

  def prevent_destruction_on_published_documents
    return false unless destroyable?
  end
end