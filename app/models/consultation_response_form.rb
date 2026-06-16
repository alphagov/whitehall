class ConsultationResponseForm < ApplicationRecord
  has_one :consultation_participation
  belongs_to :consultation_response_form_data

  delegate :url, :file, to: :consultation_response_form_data

  validates :title, :consultation_response_form_data, presence: true

  accepts_nested_attributes_for :consultation_response_form_data

  after_destroy :destroy_consultation_response_form_data_if_required

  def publicly_visible?
    return if consultation_participation.blank?

    return if consultation_participation.consultation.blank?

    consultation_participation.consultation.publicly_visible?
  end

  def deleted?
    return if consultation_participation.blank?

    return if consultation_participation.consultation.blank?

    consultation_participation.consultation.deleted?
  end

  def attachable
    return if consultation_participation.blank?

    consultation_participation.consultation
  end  

private

  def destroy_consultation_response_form_data_if_required
    unless ConsultationResponseForm.where(consultation_response_form_data_id: consultation_response_form_data.id).any?
      consultation_response_form_data.destroy!
    end
  end
end
