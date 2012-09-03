class ConsultationResponseForm < ActiveRecord::Base
  mount_uploader :file, ConsultationResponseFormUploader, mount_on: :carrierwave_file

  belongs_to :consultation_participation

  validates :file, :title, presence: true
end
