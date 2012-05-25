require 'test_helper'

class ConsultationResponseTest < ActiveSupport::TestCase
  test "should not be valid without an associated consultation" do
    consultation_response = build(:consultation_response, consultation: nil)
    refute consultation_response.valid?
  end

  test "should return latest published version of consultation" do
    consultation_response = create(:consultation_response)
    consultation = create(:draft_consultation, change_note: "change-note", doc_identity: consultation_response.consultation_doc_identity)
    consultation.publish_as(create(:departmental_editor), force: true)
    assert_equal consultation, consultation_response.reload.consultation
  end
end
