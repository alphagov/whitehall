require 'test_helper'

class ConsultationResponseTest < EditionTestCase
  should_not_allow_image_attachments
  should_be_attachable
  should_allow_inline_attachments

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
end
