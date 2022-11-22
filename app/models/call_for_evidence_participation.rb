class CallForEvidenceParticipation < ApplicationRecord
  belongs_to :call_for_evidence, foreign_key: "edition_id"
  belongs_to :call_for_evidence_response_form
  accepts_nested_attributes_for :call_for_evidence_response_form,
                                reject_if: :no_substantive_form_attributes?,
                                allow_destroy: true

  validates :link_url, uri: true, allow_blank: true
  validates :email, email_format: { allow_blank: true }

  def has_link?
    link_url.present?
  end

  def has_email?
    email.present?
  end

  def has_response_form?
    call_for_evidence_response_form.present?
  end

  def has_postal_address?
    postal_address.present?
  end

  after_destroy :destroy_form_if_required

private

  def destroy_form_if_required
    if has_response_form? &&
        CallForEvidenceParticipation.where(call_for_evidence_response_form_id: call_for_evidence_response_form.id).empty?
      call_for_evidence_response_form.destroy!
    end
  end

  def no_substantive_form_attributes?(attrs)
    attrs.except(:call_for_evidence_response_form_data_attributes, :_destroy).values.all?(&:blank?) &&
      (attrs[:call_for_evidence_response_form_data_attributes] || {}).values.all?(&:blank?)
  end
end
