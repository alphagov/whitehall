class Response < ActiveRecord::Base
  belongs_to :consultation, foreign_key: :edition_id

  has_many :consultation_response_attachments, dependent: :destroy
  has_many :attachments, through: :consultation_response_attachments

  accepts_nested_attributes_for :consultation_response_attachments,
                                reject_if: :no_substantive_attachment_attributes?,
                                allow_destroy: true

  def published?
    attachments.any?
  end

  def published_on
    consultation_response_attachments.order("created_at ASC").first.created_at if published?
  end

  def alternative_format_contact_email
    consultation.alternative_format_contact_email
  end

  private

  def no_substantive_attachment_attributes?(attrs)
    attrs.fetch(:attachment_attributes, {}).except(:accessible).values.all?(&:blank?)
  end
end