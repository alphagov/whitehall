require "test_helper"

class CallForEvidenceResponseFormDataTest < ActiveSupport::TestCase
  test "should be invalid without a file" do
    call_for_evidence_response_form_data = build(:call_for_evidence_response_form_data, file: nil)
    assert_not call_for_evidence_response_form_data.valid?
  end

  test "should return its call_for_evidence's auth_bypass_id" do
    auth_bypass_id = "86385d6a-f918-4c93-96bf-087218a48ced"
    call_for_evidence = CallForEvidence.new(id: 1, auth_bypass_id:)
    call_for_evidence_participation = build(:call_for_evidence_participation, call_for_evidence:)
    call_for_evidence_response_form = build(:call_for_evidence_response_form, call_for_evidence_participation:)
    call_for_evidence_response_form_data = build(:call_for_evidence_response_form_data, call_for_evidence_response_form:)

    assert_equal call_for_evidence_response_form_data.auth_bypass_ids, [auth_bypass_id]
  end
end
