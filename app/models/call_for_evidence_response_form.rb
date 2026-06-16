class CallForEvidenceResponseForm < ApplicationRecord
  has_one :call_for_evidence_participation
  belongs_to :call_for_evidence_response_form_data

  delegate :url, :file, to: :call_for_evidence_response_form_data

  validates :title, :call_for_evidence_response_form_data, presence: true

  accepts_nested_attributes_for :call_for_evidence_response_form_data

  after_destroy :destroy_call_for_evidence_response_form_data_if_required

  def publicly_visible?
    return if call_for_evidence_participation.blank?

    return if call_for_evidence_participation.call_for_evidence.blank?

    call_for_evidence_participation.call_for_evidence.publicly_visible?
  end

  def deleted?
    return if call_for_evidence_participation.blank?

    return if call_for_evidence_participation.call_for_evidence.blank?

    call_for_evidence_participation.call_for_evidence.deleted?
  end

  def attachable
    return if call_for_evidence_participation.blank?

    call_for_evidence_participation.call_for_evidence
  end    

private

  def destroy_call_for_evidence_response_form_data_if_required
    unless CallForEvidenceResponseForm.where(call_for_evidence_response_form_data_id: call_for_evidence_response_form_data.id).any?
      call_for_evidence_response_form_data.destroy!
    end
  end
end
