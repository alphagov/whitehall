require 'test_helper'

class Admin::StatisticsAnnouncementDatesControllerTest < ActionController::TestCase
  setup do
    @user = login_as(:policy_writer)
    @organisation = create(:organisation)
    @topic = create(:topic)
    @announcement = create(:statistics_announcement)
  end

  view_test "GET :new renders a pre-filled announcement form" do
    get :new, statistics_announcement_id: @announcement

    assert_response :success
    assert_select "input[name='statistics_announcement_date[precision]'][value='0']" do |element|
      assert element[0].attributes['checked']
    end
  end

  test "POST :create with valid params saves the date change and redirects to the announcement" do
    post :create, statistics_announcement_id: @announcement, statistics_announcement_date: {
      release_date: 1.year.from_now,
      confirmed: '1',
      precision: StatisticsAnnouncementDate::PRECISION[:exact]
    }

    assert_redirected_to admin_statistics_announcement_url(@announcement)
    announcement_date = @announcement.statistics_announcement_dates.last
    assert_equal 1.year.from_now, announcement_date.release_date
    assert announcement_date.confirmed?
    assert_equal StatisticsAnnouncementDate::PRECISION[:exact], announcement_date.precision
  end
end
