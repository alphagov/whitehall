require "test_helper"

class ConsultationResponseFormTest < ActiveSupport::TestCase
  setup do
    ConsultationResponseFormData.any_instance.stubs(:auth_bypass_ids).returns(["auth bypass id"])
  end

  test "should be invalid without a title" do
    form = build(:consultation_response_form, title: nil)
    assert_not form.valid?
  end

  test "should be invalid without a consultation_response_form_data" do
    form = build(:consultation_response_form, consultation_response_form_data: nil)
    assert_not form.valid?
  end

  test "does not destroy response form data when other response forms are associated with it" do
    consultation_response_form = create(:consultation_response_form)
    consultation_response_form_data = consultation_response_form.consultation_response_form_data
    _other_consultation_response_form = create(:consultation_response_form, consultation_response_form_data:)

    consultation_response_form_data.expects(:destroy).never
    consultation_response_form.destroy!
  end

  test "destroys response form data when no other response forms are associated with it" do
    consultation_response_form = create(:consultation_response_form)
    consultation_response_form_data = consultation_response_form.consultation_response_form_data

    consultation_response_form_data.expects(:destroy!)
    consultation_response_form.destroy!
  end

  test "#attachable returns the parent consultation" do
    consultation = build(:consultation)
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)

    assert_equal consultation, consultation_response_form.attachable
  end

  test "#attachable returns nil when there is no participation" do
    consultation_response_form = build(:consultation_response_form, consultation_participation: nil)

    assert_nil consultation_response_form.attachable
  end

  test "#deleted? returns false" do
    assert_not build(:consultation_response_form).deleted?
  end

  test "#attachable resolves to the newest edition when the response form is shared across editions" do
    published_consultation = create(:published_consultation)
    old_participation = create(:consultation_participation, consultation: published_consultation)
    response_form = build(:consultation_response_form, consultation_participation: nil)
    old_participation.update!(consultation_response_form: response_form)

    draft_consultation = published_consultation.create_draft(create(:gds_editor))
    draft_consultation.reload

    response_form.reload

    assert_equal draft_consultation, response_form.attachable
  end
end
