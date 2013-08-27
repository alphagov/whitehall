require "test_helper"

class FatalityNoticeTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_allow_role_appointments
  should_allow_image_attachments
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test "is only valid with a field of operation" do
    refute build(:fatality_notice, operational_field: nil).valid?

    operational_field = build(:operational_field)
    assert build(:fatality_notice, operational_field: operational_field).valid?
  end

  test 'is not valid without a roll call introduction' do
    refute build(:fatality_notice, roll_call_introduction: nil).valid?
  end

  test "has operational field" do
    assert build(:fatality_notice).has_operational_field?
  end

  test "casualties are persisted across new editions" do
    notice = create(:published_fatality_notice, operational_field: create(:operational_field), )
    casualty = create(:fatality_notice_casualty, fatality_notice: notice)
    assert_equal 1, notice.fatality_notice_casualties.length
    new_notice = notice.create_draft(build(:user))
    assert_equal 1, new_notice.fatality_notice_casualties.length
  end

  test 'search_format_types tags the fatality notice as a fatality-notice and announcement' do
    fatality_notice = build(:fatality_notice)
    assert fatality_notice.search_format_types.include?('fatality-notice')
    assert fatality_notice.search_format_types.include?('announcement')
  end

  test "search_index includes slug of operational field" do
    operational_field = create(:operational_field)
    fatality_notice = create(:published_fatality_notice, operational_field: operational_field)
    assert_equal operational_field.slug, fatality_notice.search_index["operational_field"]
  end
end
