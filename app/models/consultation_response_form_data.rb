# == Schema Information
#
# Table name: consultation_response_form_data
#
#  id               :integer          not null, primary key
#  carrierwave_file :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class ConsultationResponseFormData < ActiveRecord::Base
  mount_uploader :file, ConsultationResponseFormUploader, mount_on: :carrierwave_file

  has_one :consultation_response_form

  validates :file, presence: true
end
