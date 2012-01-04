require 'test_helper'

class ConsultationResponseTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    consultation_response = build(:consultation_response)
    assert consultation_response.valid?
  end

  test "should not be valid without an associated consultation" do
    consultation_response = build(:consultation_response, consultation: nil)
    refute consultation_response.valid?
  end

  test "should return latest published version of consultation" do
    consultation_response = create(:consultation_response)
    consultation = create(:draft_consultation, document_identity: consultation_response.consultation_document_identity)
    consultation.publish_as(create(:departmental_editor), force: true)
    assert_equal consultation, consultation_response.reload.consultation
  end
end