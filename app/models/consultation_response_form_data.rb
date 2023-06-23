class ConsultationResponseFormData < ApplicationRecord
  mount_uploader :file, ResponseDocumentUploader, mount_on: :carrierwave_file

  has_one :consultation_response_form

  validates :file, presence: true

  def auth_bypass_ids
    [consultation_response_form.consultation_participation.consultation.auth_bypass_id]
  end
end
