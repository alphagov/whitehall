class Response < ActiveRecord::Base
  include Attachable

  belongs_to :consultation, foreign_key: :edition_id
  has_many :consultation_response_attachments, dependent: :destroy
  has_many :attachments, through: :consultation_response_attachments, order: [:ordering, :id], before_add: :set_order

  validates :published_on, recent_date: true, presence: true
  validates :summary, presence: true, on: :create
  validates_with SafeHtmlValidator

  def published?
    attachments.any?
  end

  def alternative_format_contact_email
    consultation.alternative_format_contact_email
  end

  def can_order_attachments?
    true
  end
end
