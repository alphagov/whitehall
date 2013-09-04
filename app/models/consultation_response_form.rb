# == Schema Information
#
# Table name: consultation_response_forms
#
#  id                                 :integer          not null, primary key
#  title                              :string(255)
#  created_at                         :datetime
#  updated_at                         :datetime
#  consultation_response_form_data_id :integer
#

class ConsultationResponseForm < ActiveRecord::Base
  has_one :consultation_participation
  belongs_to :consultation_response_form_data

  delegate :url, :file, to: :consultation_response_form_data

  validates :title, presence: true

  accepts_nested_attributes_for :consultation_response_form_data

  after_destroy :destroy_consultation_response_form_data_if_required

  private
  def destroy_consultation_response_form_data_if_required
    unless ConsultationResponseForm.where(consultation_response_form_data_id: consultation_response_form_data.id).any?
      consultation_response_form_data.destroy
    end
  end

end
