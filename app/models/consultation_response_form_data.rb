class ConsultationResponseFormData < ApplicationRecord
  mount_uploader :file, ConsultationResponseFormUploader, mount_on: :carrierwave_file

  has_one :consultation_response_form

  validates :file, presence: true
end
