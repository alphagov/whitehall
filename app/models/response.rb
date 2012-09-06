class Response < ActiveRecord::Base
  has_many :consultation_response_attachments, dependent: :destroy
  has_many :attachments, through: :consultation_response_attachments

  accepts_nested_attributes_for :consultation_response_attachments,
                                reject_if: :no_substantive_attachment_attributes?,
                                allow_destroy: true

  private

  def no_substantive_attachment_attributes?(attrs)
    attrs.fetch(:attachment_attributes, {}).except(:accessible).values.all?(&:blank?)
  end
end