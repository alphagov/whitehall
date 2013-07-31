require 'test_helper'

class ResponseTest < ActiveSupport::TestCase
  test 'destroys attachments when the response is destroyed' do
    response = create(:consultation_outcome)
    response_attachment = response.consultation_response_attachments.create!
    response.destroy

    assert_nil ConsultationResponseAttachment.find_by_id(response_attachment.id)
  end

  test "legacy responses without a summary are still valid" do
    response = create(:consultation_outcome)
    response.update_column(:summary, nil)
    assert response.reload.valid?
  end

  test "should return the alternative_format_contact_email of the consultation" do
    consultation = build(:consultation)
    consultation.stubs(alternative_format_contact_email: 'alternative format contact email')
    response = build(:consultation_outcome, consultation: consultation)

    assert_equal consultation.alternative_format_contact_email, response.alternative_format_contact_email
  end
end
