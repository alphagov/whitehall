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

  test 'only gds editors and ONS users have access' do
    login_as(:policy_writer)
    get :new, statistics_announcement_id: @announcement
    assert_response :forbidden

    login_as(:gds_editor)
    get :new, statistics_announcement_id: @announcement
    assert_response :success

    ons_user = create(:user, organisation: create(:organisation, name: 'Office for National Statistics'))
    login_as(ons_user)
    get :new, statistics_announcement_id: @announcement
    assert_response :success
  end

  view_test "GET :new renders a pre-filled announcement form" do
    get :new, statistics_announcement_id: @announcement

    assert_response :success
    assert_select "input[name='statistics_announcement_date_change[precision]'][value='1']" do |element|
      assert element[0].attributes['checked']
    end
  end

  test "POST :create with valid params saves the date change and redirects to the announcement" do
    new_date =Time.zone.local(2013, 05, 11, 9, 30)
    post :create, statistics_announcement_id: @announcement, statistics_announcement_date_change: {
      release_date: new_date,
      confirmed: '1',
      precision: StatisticsAnnouncementDate::PRECISION[:exact],
      change_note: 'Delayed due to unexpected beard growth'
    }

    @announcement.reload
    assert_redirected_to admin_statistics_announcement_url(@announcement)
    assert_equal new_date, @announcement.release_date
    assert @announcement.confirmed?
    assert_equal '11 May 2013 09:30', @announcement.display_date
    assert_equal 'Delayed due to unexpected beard growth', @announcement.last_change_note
    assert_equal @user, @announcement.statistics_announcement_dates.last.creator
  end
end
