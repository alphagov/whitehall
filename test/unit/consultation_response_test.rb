require 'test_helper'

class ConsultationResponseTest < ActiveSupport::TestCase
  include DocumentBehaviour

  should_be_attachable :consultation_response

  test "should not be valid without an associated consultation" do
    consultation_response = build(:consultation_response, consultation: nil)
    refute consultation_response.valid?
  end

  test "should return latest published version of consultation" do
    consultation_response = create(:consultation_response)
    consultation = create(:draft_consultation, change_note: "change-note", document: consultation_response.consultation_document)
    consultation.publish_as(create(:departmental_editor), force: true)
    assert_equal consultation, consultation_response.reload.consultation
  end

  test "should get alternative_format_contact_email from the last published consultation" do
    email_address = "alternative@example.com"
    organisation = create(:organisation, alternative_format_contact_email: email_address)
    consultation = create(:published_consultation, alternative_format_provider: organisation)
    consultation_response = create(:published_consultation_response, consultation_document: consultation.document)
    assert_equal email_address, consultation_response.alternative_format_contact_email
  end

  test "should not use the contact email of an unpublished draft of the consultation" do
    consultation = create(:published_consultation, alternative_format_provider: nil)
    organisation = create(:organisation, alternative_format_contact_email: "alternative@example.com")
    draft_consultation = create(:draft_consultation, alternative_format_provider: organisation, document: consultation.document)
    consultation_response = create(:published_consultation_response, consultation_document: consultation.document)
    assert_equal nil, consultation_response.alternative_format_contact_email
  end
end
