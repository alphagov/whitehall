require 'test_helper'

class Admin::StatisticsAnnouncementsControllerTest < ActionController::TestCase
  setup do
    @user = login_as(:policy_writer)
    @organisation = create(:organisation)
    @topic = create(:topic)
  end

  view_test "GET :new renders a new announcement form" do
    get :new

    assert_response :success
    assert_select "input[name='statistics_announcement[title]']"
  end

  test "POST :create saves the announcement to the database and redirects to the dashboard" do
    post :create, statistics_announcement: {
                    title: 'Beard stats 2014',
                    summary: 'Summary text',
                    publication_type_id: PublicationType::Statistics.id,
                    organisation_id: @organisation.id,
                    topic_id: @topic.id,
                    expected_release_date: 1.year.from_now }

    assert_redirected_to admin_root_url
    assert announcement = StatisticsAnnouncement.last
    assert_equal 'Beard stats 2014', announcement.title
    assert_equal @organisation, announcement.organisation
    assert_equal @user, announcement.creator
  end

  view_test "POST :create re-renders the form if the announcement is invalid" do
    post :create, statistics_announcement: { title: '', summary: 'Summary text' }

    assert_response :success
    assert_select "ul.errors li", text: "Title can&#x27;t be blank"
    refute StatisticsAnnouncement.any?
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

    assert_redirected_to admin_root_url
    assert_equal 'New announcement title', announcement.reload.title
  end

  test "PUT :update redirects back to the edit screen if updating the publication" do
    announcement = create(:statistics_announcement)
    publication  = create(:submitted_statistics)
    put :update, id: announcement.id, statistics_announcement: { publication_id: publication.id }

    assert_redirected_to edit_admin_statistics_announcement_path(announcement)
    assert_equal publication, announcement.reload.publication
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

    assert_redirected_to admin_root_url
    refute StatisticsAnnouncement.exists?(announcement)
    assert_equal "Announcement deleted successfully", flash[:notice]
  end
end
