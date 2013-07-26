class Response < ActiveRecord::Base
  belongs_to :consultation, foreign_key: :edition_id

  has_many :consultation_response_attachments, dependent: :destroy
  has_many :attachments, through: :consultation_response_attachments, order: [:ordering, :id], before_add: :set_order

  validates :published_on, recent_date: true, presence: true

  def published?
    published_on.present? && (summary.present? || attachments.any?)
  end

  def alternative_format_contact_email
    consultation.alternative_format_contact_email
  end

  def allows_attachment_references?
    false
  end

  def can_order_attachments?
    !allows_inline_attachments?
  end

  def allows_inline_attachments?
    false
  end

  private

  def set_order(new_attachment)
    new_attachment.ordering = next_ordering unless new_attachment.ordering.present?
  end

  def next_ordering
    max = attachments.maximum(:ordering)
    max ? max + 1 : 0
  end
end
