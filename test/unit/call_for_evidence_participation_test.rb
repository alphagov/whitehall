require "test_helper"

class CallForEvidenceParticipationTest < ActiveSupport::TestCase
  setup do
    CallForEvidenceResponseFormData.any_instance.stubs(:auth_bypass_ids).returns(["auth bypass id"])
  end

  test "should be invalid with malformed link url" do
    participation = build(:call_for_evidence_participation, link_url: "invalid-url")
    assert_not participation.valid?
  end

  test "should be valid with link url with HTTP protocol" do
    participation = build(:call_for_evidence_participation, link_url: "http://example.com")
    assert participation.valid?
  end

  test "should be valid with link url with HTTPS protocol" do
    participation = build(:call_for_evidence_participation, link_url: "https://example.com")
    assert participation.valid?
  end

  test "should be valid without link url" do
    participation = build(:call_for_evidence_participation, link_url: nil)
    assert participation.valid?
  end

  test "should be invalid with malformed email" do
    participation = build(:call_for_evidence_participation, email: "invalid-email")
    assert_not participation.valid?
  end

  test "should be valid without an email" do
    participation = build(:call_for_evidence_participation, email: nil)
    assert participation.valid?
  end

  test "allows attachment of a call_for_evidence response form" do
    form = build(:call_for_evidence_response_form)
    assert build(:call_for_evidence_participation, call_for_evidence_response_form: form).valid?
  end

  test "should allow building of response forms via nested attributes" do
    data_attributes = attributes_for(:call_for_evidence_response_form_data)
    form_attributes = attributes_for(:call_for_evidence_response_form, call_for_evidence_response_form_data_attributes: data_attributes)
    participation = build(:call_for_evidence_participation, call_for_evidence_response_form_attributes: form_attributes)
    assert participation.valid?
  end

  test "should be invalid if the response form has no title" do
    data_attributes = attributes_for(:call_for_evidence_response_form_data)
    form_attributes = attributes_for(:call_for_evidence_response_form, title: nil, call_for_evidence_response_form_data_attributes: data_attributes)
    participation = build(:call_for_evidence_participation, call_for_evidence_response_form_attributes: form_attributes)
    assert_not participation.valid?
  end

  test "should be invalid if the response form's data has no file" do
    participation = build(:call_for_evidence_participation, call_for_evidence_response_form: build(:call_for_evidence_response_form, file: nil))
    assert_not participation.valid?
  end

  test "should allow deletion of response form via nested attributes" do
    AssetManagerDeleteAssetWorker.stubs(:perform_async)

    form = create(:call_for_evidence_response_form)
    participation = create(:call_for_evidence_participation, call_for_evidence_response_form: form)

    participation.update!(call_for_evidence_response_form_attributes: { id: form.id, "_destroy" => "1" })

    participation.reload
    assert_not participation.call_for_evidence_response_form.present?
  end

  test "destroys attached form when no editions are associated" do
    AssetManagerDeleteAssetWorker.stubs(:perform_async)

    participation = create(:call_for_evidence_participation)
    form = create(:call_for_evidence_response_form, call_for_evidence_participation: participation)

    participation.destroy!

    assert_raise(ActiveRecord::RecordNotFound) do
      form.reload
    end
  end

  test "does not destroy attached file when if more participations are associated" do
    participation = create(:call_for_evidence_participation)

    form = create(:call_for_evidence_response_form, call_for_evidence_participation: participation)
    _other_participation = create(:call_for_evidence_participation, call_for_evidence_response_form: form)

    participation.destroy!

    assert_nothing_raised do
      form.reload
    end
  end

  test "can be destroyed without an associated form" do
    participation = create(:call_for_evidence_participation, call_for_evidence_response_form: nil)
    participation.destroy!
    assert_raise(ActiveRecord::RecordNotFound) do
      participation.reload
    end
  end
end
