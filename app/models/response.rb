class Response < ActiveRecord::Base
  include Attachable

  belongs_to :consultation, foreign_key: :edition_id

  validates :published_on, recent_date: true, presence: true
  validates_presence_of :summary, unless: :has_attachments
  validates_with SafeHtmlValidator

  def alternative_format_contact_email
    consultation.alternative_format_contact_email
  end

  def can_order_attachments?
    true
  end

  private

  def has_attachments
    attachments.any?
  end
end
