# == Schema Information
#
# Table name: responses
#
#  id           :integer          not null, primary key
#  edition_id   :integer
#  summary      :text
#  created_at   :datetime
#  updated_at   :datetime
#  published_on :date
#  type         :string(255)
#

class Response < ActiveRecord::Base
  include Attachable

  belongs_to :consultation, foreign_key: :edition_id
  has_many :consultation_response_attachments, dependent: :destroy
  has_many :attachments, through: :consultation_response_attachments, order: [:ordering, :id], before_add: :set_order

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
