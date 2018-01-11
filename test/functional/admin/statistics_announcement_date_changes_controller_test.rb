require 'test_helper'

class Admin::StatisticsAnnouncementDateChangesControllerTest < ActionController::TestCase
  setup do
    Timecop.travel(1.day.ago) do
      @user = login_as(:gds_editor)
      @organisation = create(:organisation)
      @topic = create(:topic)
      @announcement = create(:statistics_announcement)
    end
  end

  view_test "GET :new renders a pre-filled announcement form" do
    get :new, params: { statistics_announcement_id: @announcement }

    assert_response :success
    assert_select "input[name='statistics_announcement_date_change[precision]'][value='1']" do |element|
      assert element[0].attributes['checked']
    end

    assert_select("select#statistics_announcement_date_change_release_date_1i option[selected]") do |element|
      assert_equal @announcement.release_date.year, element.first['value'].to_i
    end

    assert_select("select#statistics_announcement_date_change_release_date_2i option[selected]") do |element|
      assert_equal @announcement.release_date.month, element.first['value'].to_i
    end

    assert_select("select#statistics_announcement_date_change_release_date_3i option[selected]") do |element|
      assert_equal @announcement.release_date.day, element.first['value'].to_i
    end

    assert_select("select#statistics_announcement_date_change_release_date_4i option[selected]") do |element|
      assert_equal @announcement.release_date.hour, element.first['value'].to_i
    end

    assert_select("select#statistics_announcement_date_change_release_date_5i option[selected]") do |element|
      assert_equal @announcement.release_date.min, element.first['value'].to_i
    end
  end

  view_test "GET :new only shows change notes field when the release date is confirmed" do
    get :new, params: { statistics_announcement_id: @announcement }

    assert_response :success
    refute_select('textarea#statistics_announcement_date_change_change_note')

    @announcement.current_release_date.update_attribute(:confirmed, true)
    get :new, params: { statistics_announcement_id: @announcement }

    assert_response :success
    assert_select('textarea#statistics_announcement_date_change_change_note')
  end

  test "POST :create with valid params saves the date change and redirects to the announcement" do
    new_date = Time.zone.local(2013, 5, 11, 9, 30)
    post :create, params: { statistics_announcement_id: @announcement, statistics_announcement_date_change: {
      release_date: new_date,
      confirmed: '1',
      precision: StatisticsAnnouncementDate::PRECISION[:exact]
    } }

    @announcement.reload
    assert_redirected_to admin_statistics_announcement_url(@announcement)
    assert_equal new_date, @announcement.release_date
    assert @announcement.confirmed?
    assert_equal '11 May 2013 9:30am', @announcement.display_date
    assert_equal @user, @announcement.statistics_announcement_dates.last.creator
  end
end
