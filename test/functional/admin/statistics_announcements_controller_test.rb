require 'test_helper'

class Admin::StatisticsAnnouncementsControllerTest < ActionController::TestCase
  setup do
    @organisation = create(:organisation)
    @user = login_as create(:gds_editor, organisation: @organisation)
    @topic = create(:topic)
  end

  view_test "GET :new renders a new announcement form" do
    get :new

    assert_response :success
    assert_select "input[name='statistics_announcement[title]']"
  end

  test "GET :index filters announcements by the current user's organisation by default" do
    @organsation_announcement = create(:statistics_announcement, organisation: @organisation)
    @other_announcement       = create(:statistics_announcement)

    get :index

    assert_equal [@organsation_announcement], assigns(:statistics_announcements)
  end

  test "POST :create saves the announcement to the database and redirects to the dashboard" do
    post :create, statistics_announcement: {
                    title: 'Beard stats 2014',
                    summary: 'Summary text',
                    publication_type_id: PublicationType::Statistics.id,
                    organisation_id: @organisation.id,
                    topic_id: @topic.id,
                    current_release_date_attributes: {
                      release_date: 1.year.from_now,
                      precision: StatisticsAnnouncementDate::PRECISION[:one_month],
                      confirmed: '0'
                    }
                  }

    assert_response :redirect
    assert announcement = StatisticsAnnouncement.last
    assert_equal 'Beard stats 2014', announcement.title
    assert_equal @organisation, announcement.organisation
    assert_equal @user, announcement.creator
    assert_equal 'November 2012', announcement.display_date
    assert_equal @user, announcement.current_release_date.creator
  end

  view_test "POST :create re-renders the form if the announcement is invalid" do
    post :create, statistics_announcement: { title: '', summary: 'Summary text' }

    assert_response :success
    assert_select "ul.errors li", text: "Title can&#x27;t be blank"
    refute StatisticsAnnouncement.any?
  end

  view_test "GET :show renders the details of the announcement" do
    announcement = create(:statistics_announcement)
    get :show, id: announcement

    assert_response :success
    assert_select 'h1 .stats-heading', text: announcement.title
  end

  view_test "GET :edit renders the edit form for the  announcement" do
    announcement = create(:statistics_announcement)
    get :edit, id: announcement.id

    assert_response :success
    assert_select "input[name='statistics_announcement[title]'][value='#{announcement.title}']"
  end

  test "PUT :update saves changes to the announcement" do
    announcement = create(:statistics_announcement)
    put :update, id: announcement.id, statistics_announcement: { title: "New announcement title" }

    assert_response :redirect
    assert_equal 'New announcement title', announcement.reload.title
  end

  view_test "PUT :update re-renders edit form if changes are not valid" do
    announcement = create(:statistics_announcement)
    put :update, id: announcement.id, statistics_announcement: { title: '' }

    assert_response :success
    assert_select "ul.errors li", text: "Title can&#x27;t be blank"
  end

  test "DELETE :destroy deletes the announcement" do
    announcement = create(:statistics_announcement)
    delete :destroy, id: announcement.id

    assert_redirected_to admin_statistics_announcements_url
    refute StatisticsAnnouncement.exists?(announcement)
    assert_equal "Announcement deleted successfully", flash[:notice]
  end
end
