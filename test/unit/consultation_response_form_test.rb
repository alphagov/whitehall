require 'test_helper'

class ConsultationResponseFormTest < ActiveSupport::TestCase
  test 'should be invalid without a title' do
    form = build(:consultation_response_form, title: nil)
    refute form.valid?
  end

  test "does not destroy response form data when other response forms are associated with it" do
    consultation_response_form = create(:consultation_response_form)
    consultation_response_form_data = consultation_response_form.consultation_response_form_data
    _other_consultation_response_form = create(:consultation_response_form, consultation_response_form_data: consultation_response_form_data)

    consultation_response_form_data.expects(:destroy).never
    consultation_response_form.destroy
  end

  test "destroys response form data when no other response forms are associated with it" do
    consultation_response_form = create(:consultation_response_form)
    consultation_response_form_data = consultation_response_form.consultation_response_form_data

    consultation_response_form_data.expects(:destroy)
    consultation_response_form.destroy
  end
end
