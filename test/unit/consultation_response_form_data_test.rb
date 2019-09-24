require "test_helper"

class ConsultationResponseFormDataTest < ActiveSupport::TestCase
  test "should be invalid without a file" do
    consultation_response_form_data = build(:consultation_response_form_data, file: nil)
    refute consultation_response_form_data.valid?
  end
end
