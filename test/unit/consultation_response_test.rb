require 'test_helper'

class ConsultationResponseTest < EditionTestCase
  should_not_allow_image_attachments
  should_be_attachable
  should_not_allow_inline_attachments
  should_allow_a_summary_to_be_written
  should_not_allow_a_body_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

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

  test "should return the latest edition of a consultation if no published edition exists" do
    consultation = create(:draft_consultation, change_note: "change-note")
    consultation_response = create(:consultation_response, consultation: consultation)
    assert_equal consultation, consultation_response.reload.consultation
  end
end
