class CallForEvidenceResponseForm < ApplicationRecord
  has_one :call_for_evidence_participation
  belongs_to :call_for_evidence_response_form_data

  delegate :url, :file, to: :call_for_evidence_response_form_data

  validates :title, presence: true

  accepts_nested_attributes_for :call_for_evidence_response_form_data

  after_destroy :destroy_call_for_evidence_response_form_data_if_required

private

  def destroy_call_for_evidence_response_form_data_if_required
    unless CallForEvidenceResponseForm.where(call_for_evidence_response_form_data_id: call_for_evidence_response_form_data.id).any?
      call_for_evidence_response_form_data.destroy!
    end
  end
end
