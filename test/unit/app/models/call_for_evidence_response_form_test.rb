require "test_helper"

class CallForEvidenceResponseFormTest < ActiveSupport::TestCase
  setup do
    CallForEvidenceResponseFormData.any_instance.stubs(:auth_bypass_ids).returns(["auth bypass id"])
  end

  test "should be invalid without a title" do
    form = build(:call_for_evidence_response_form, title: nil)
    assert_not form.valid?
  end

  test "should be invalid without call_for_evidence_response_form_data" do
    call_for_evidence = build(:call_for_evidence_response_form, call_for_evidence_response_form_data: nil)
    assert_not call_for_evidence.valid?
  end

  test "does not destroy response form data when other response forms are associated with it" do
    call_for_evidence_response_form = create(:call_for_evidence_response_form)
    call_for_evidence_response_form_data = call_for_evidence_response_form.call_for_evidence_response_form_data
    _other_call_for_evidence_response_form = create(:call_for_evidence_response_form, call_for_evidence_response_form_data:)

    call_for_evidence_response_form_data.expects(:destroy).never
    call_for_evidence_response_form.destroy!
  end

  test "destroys response form data when no other response forms are associated with it" do
    call_for_evidence_response_form = create(:call_for_evidence_response_form)
    call_for_evidence_response_form_data = call_for_evidence_response_form.call_for_evidence_response_form_data

    call_for_evidence_response_form_data.expects(:destroy!)
    call_for_evidence_response_form.destroy!
  end

  test ".attachable returns associated CallForEvidence if it is exists" do
    call_for_evidence = build(:call_for_evidence)
    call_for_evidence_participation = build(:call_for_evidence_participation, call_for_evidence:)
    call_for_evidence_response_form = build(:call_for_evidence_response_form, call_for_evidence_participation:)

    assert call_for_evidence_response_form.attachable, call_for_evidence
  end

  test ".attachable returns Attachable::Null if no associated CallForEvidence" do
    call_for_evidence_response_form = build(:call_for_evidence_response_form)

    assert call_for_evidence_response_form.attachable, Attachable::Null
  end
end
