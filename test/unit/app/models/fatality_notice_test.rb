require "test_helper"

class FatalityNoticeTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_role_appointments
  should_allow_image_attachments
  should_protect_against_xss_and_content_attacks_on :fatality_notice, :title, :body, :summary, :change_note

  test "is only valid with a field of operation" do
    assert_not build(:fatality_notice, operational_field: nil).valid?

    operational_field = build(:operational_field)
    assert build(:fatality_notice, operational_field:).valid?
  end

  test "is not valid without a roll call introduction" do
    assert_not build(:fatality_notice, roll_call_introduction: nil).valid?
  end

  test "has operational field" do
    assert build(:fatality_notice).has_operational_field?
  end

  test "casualties are persisted across new editions" do
    notice = create(:published_fatality_notice, operational_field: create(:operational_field))
    _casualty = create(:fatality_notice_casualty, fatality_notice: notice)
    assert_equal 1, notice.fatality_notice_casualties.length
    new_notice = notice.create_draft(build(:user))
    assert_equal 1, new_notice.fatality_notice_casualties.length
  end

  test "is not able to be marked political" do
    fatality_notice = build(:fatality_notice)
    assert_not fatality_notice.can_be_marked_political?
  end

  test "is rendered by frontend" do
    assert FatalityNotice.new.rendering_app == Whitehall::RenderingApp::FRONTEND
  end
end
