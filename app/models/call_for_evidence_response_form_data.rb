class CallForEvidenceResponseFormData < ApplicationRecord
  mount_uploader :file, ResponseDocumentUploader, mount_on: :carrierwave_file

  has_one :call_for_evidence_response_form

  validates :file, presence: true

  def auth_bypass_ids
    [call_for_evidence_response_form.call_for_evidence_participation.call_for_evidence.auth_bypass_id]
  end
end
