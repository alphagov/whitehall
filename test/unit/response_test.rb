require 'test_helper'

class ResponseTest < ActiveSupport::TestCase
  test "responses without a summary are only valid if they have attachments" do
    response = build(:consultation_outcome, summary: nil)
    refute response.valid?

    response.attachments << build(:attachment)
    assert response.valid?, response.errors.full_messages.inspect
  end

  test "should return the alternative_format_contact_email of the consultation" do
    consultation = build(:consultation)
    consultation.stubs(alternative_format_contact_email: 'alternative format contact email')
    response = build(:consultation_outcome, consultation: consultation)

    assert_equal consultation.alternative_format_contact_email, response.alternative_format_contact_email
  end
end
