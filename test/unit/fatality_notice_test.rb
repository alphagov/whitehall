require "test_helper"

class FatalityNoticeTest < EditionTestCase
  should_allow_image_attachments
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note
  should_allow_role_appointments

  test "is only valid with a field of operation" do
    refute build(:fatality_notice, operational_field: nil).valid?

    operational_field = build(:operational_field)
    assert build(:fatality_notice, operational_field: operational_field).valid?
  end
end
