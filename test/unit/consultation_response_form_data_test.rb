require "test_helper"

class ConsultationResponseFormDataTest < ActiveSupport::TestCase
  test "should be invalid without a file" do
    consultation_response_form_data = build(:consultation_response_form_data, file: nil)
    assert_not consultation_response_form_data.valid?
  end

  test "should return its consultation's auth_bypass_id" do
    auth_bypass_id = "86385d6a-f918-4c93-96bf-087218a48ced"
    consultation = Consultation.new(id: 1, auth_bypass_id:)
    consultation_participation = build(:consultation_participation, consultation:)
    consultation_response_form = build(:consultation_response_form, consultation_participation:)
    consultation_response_form_data = build(:consultation_response_form_data, consultation_response_form:)

    assert_equal consultation_response_form_data.auth_bypass_ids, [auth_bypass_id]
  end
end
