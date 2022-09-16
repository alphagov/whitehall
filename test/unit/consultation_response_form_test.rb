require "test_helper"

class ConsultationResponseFormTest < ActiveSupport::TestCase
  setup do
    ConsultationResponseFormData.any_instance.stubs(:auth_bypass_ids).returns(["auth bypass id"])
  end

  test "should be invalid without a title" do
    form = build(:consultation_response_form, title: nil)
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
end
