require 'test_helper'

class Admin::StatisticsAnnouncementDateChangesControllerTest < ActionController::TestCase
  setup do
    Timecop.travel(1.day.ago) do
      @user = login_as(:policy_writer)
      @organisation = create(:organisation)
      @topic = create(:topic)
      @announcement = create(:statistics_announcement)
    end
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
    assert @announcement.confirmed_date?
    assert_equal '11 May 2013 09:30', @announcement.display_date
    assert_equal 'Delayed due to unexpected beard growth', @announcement.last_change_note
  end
end
