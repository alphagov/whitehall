require 'test_helper'

class ResponseTest < ActiveSupport::TestCase
  test 'should destroy consultation response attachments when the response is destroyed' do
    response = create(:response)
    response_attachment = response.consultation_response_attachments.create!

    response.destroy

    assert_nil ConsultationResponseAttachment.find_by_id(response_attachment.id)
  end

  test "is only published if a summary or attachment is present" do
    refute build(:response).published?
    assert build(:response, summary: 'has a summary').published?
    assert build(:response, attachments: [build(:attachment)]).published?
  end

  test "should return the alternative_format_contact_email of the consultation" do
    consultation = build(:consultation)
    consultation.stubs(alternative_format_contact_email: 'alternative format contact email')
    response = build(:response, consultation: consultation)

    assert_equal consultation.alternative_format_contact_email, response.alternative_format_contact_email
  end
end
