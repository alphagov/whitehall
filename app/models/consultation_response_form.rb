class ConsultationResponseForm < ApplicationRecord
  has_one :consultation_participation
  belongs_to :consultation_response_form_data

  delegate :url, :file, to: :consultation_response_form_data

  validates :title, :consultation_response_form_data, presence: true

  accepts_nested_attributes_for :consultation_response_form_data

  after_destroy :destroy_consultation_response_form_data_if_required

  def attachable
    consultation_participation&.consultation
  end

  # AssetData calls #deleted? on each attachments item but response forms have no soft-delete state
  # (unlike Attachment/Image) so there's only one correct answer: false
  def deleted?
    false
  end

private

  def destroy_consultation_response_form_data_if_required
    unless ConsultationResponseForm.where(consultation_response_form_data_id: consultation_response_form_data.id).any?
      consultation_response_form_data.destroy!
    end
  end
end
