require 'test_helper'

class Admin::StatisticsAnnouncementsControllerTest < ActionController::TestCase
  include TaxonomyHelper

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

  test "GET :index defaults to future-dated announcements by the current user's organisation" do
    @future_announcement = create(:statistics_announcement,
                            organisation_ids: [@organisation.id],
                            current_release_date: create(:statistics_announcement_date, release_date: 1.week.from_now))
    @past_announcement   = create(:statistics_announcement,
                             organisation_ids: [@organisation.id],
                             current_release_date: create(:statistics_announcement_date, release_date: 1.day.ago))
    @other_announcement  = create(:statistics_announcement)

    get :index

    assert_equal [@future_announcement], assigns(:statistics_announcements)
  end

  test "GET :index handles users without an organisation" do
    login_as create(:gds_editor, organisation: nil)
    get :index

    assert_response :success
  end

  test "POST :create saves the announcement to the database and redirects to the dashboard" do
    post :create, params: {
                    statistics_announcement: {
                                    title: 'Beard stats 2014',
                                    summary: 'Summary text',
                                    publication_type_id: PublicationType::OfficialStatistics.id,
                                    organisation_ids: [@organisation.id],
                                    topic_ids: [@topic.id],
                                    current_release_date_attributes: {
                                      release_date: 1.year.from_now,
                                      precision: StatisticsAnnouncementDate::PRECISION[:one_month],
                                      confirmed: '0'
                                    }
                                  }
    }

    assert_response :redirect
    assert announcement = StatisticsAnnouncement.last
    assert_equal 'Beard stats 2014', announcement.title
    assert_includes announcement.organisations, @organisation
    assert_equal @user, announcement.creator
    assert_equal 'November 2012', announcement.display_date
    assert_equal @user, announcement.current_release_date.creator
  end

  view_test "POST :create re-renders the form if the announcement is invalid" do
    post :create, params: { statistics_announcement: { title: '', summary: 'Summary text' } }

    assert_response :success
    assert_select "ul.errors li", text: "Title can't be blank"
    refute StatisticsAnnouncement.any?
  end

  view_test "GET :show renders the details of the announcement" do
    announcement = create(:statistics_announcement)
    get :show, params: { id: announcement }

    assert_response :success
    assert_select 'h1 .stats-heading', text: announcement.title
  end

  view_test "GET :edit renders the edit form for the  announcement" do
    announcement = create(:statistics_announcement)
    get :edit, params: { id: announcement.id }

    assert_response :success
    assert_select "input[name='statistics_announcement[title]'][value='#{announcement.title}']"
  end

  test "PUT :update saves changes to the announcement" do
    announcement = create(:statistics_announcement)
    put :update, params: { id: announcement.id, statistics_announcement: { title: "New announcement title" } }

    assert_response :redirect
    assert_equal 'New announcement title', announcement.reload.title
  end

  view_test "PUT :update re-renders edit form if changes are not valid" do
    announcement = create(:statistics_announcement)
    put :update, params: { id: announcement.id, statistics_announcement: { title: '' } }

    assert_response :success
    assert_select "ul.errors li", text: "Title can't be blank"
  end

  test "POST :publish_cancellation cancels the announcement" do
    announcement = create(:statistics_announcement)
    post :publish_cancellation,
          params: {
            id: announcement.id,
            statistics_announcement: { cancellation_reason: "Reason" }
          }

    assert_redirected_to [:admin, announcement]
    assert announcement.reload.cancelled?
    assert_equal "Reason", announcement.cancellation_reason
    assert_equal Time.zone.now, announcement.cancelled_at
  end

  test "cancelled announcements cannot be cancelled" do
    announcement = create(:cancelled_statistics_announcement)

    get :cancel, params: { id: announcement }
    assert_redirected_to [:admin, announcement]

    post :publish_cancellation,
          params: {
            id: announcement.id,
            statistics_announcement: { cancellation_reason: "Reason" }
          }
    assert_redirected_to [:admin, announcement]
  end

  view_test "when announcement is not from an organisation with tagging enabled, don't show a button to tag to the new taxonomy" do
    draft_announcement = create(:statistics_announcement)

    announcement_has_no_expanded_links(draft_announcement.content_id)
    get :show, params: { id: draft_announcement }

    refute_select '.taxonomy-topics'
  end

  view_test "when announcement is from an organisation with tagging enabled, show a button to tag to the new taxonomy" do
    dfe_organisation = create(:organisation, content_id: "ebd15ade-73b2-4eaf-b1c3-43034a42eb37")

    announcement = create(
      :statistics_announcement,
      organisations: [dfe_organisation]
    )

    login_as(create(:user, organisation: dfe_organisation))

    announcement_has_no_expanded_links(announcement.content_id)
    get :show, params: { id: announcement }

    assert_select '.taxonomy-topics .btn', "Add topic"
  end

  view_test "when announcement is not tagged to the new taxonomy" do
    sfa_organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")

    announcement = create(
      :statistics_announcement,
      organisations: [sfa_organisation]
    )

    login_as(create(:user, organisation: sfa_organisation))

    announcement_has_no_expanded_links(announcement.content_id)
    get :show, params: { id: announcement }

    refute_select '.taxonomy-topics .content'
    assert_select '.taxonomy-topics .no-content', "No topics - please add a topic"
  end

  view_test "when announcement is tagged to the new taxonomy" do
    sfa_organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")

    announcement = create(
      :statistics_announcement,
      organisations: [sfa_organisation]
    )

    login_as(create(:user, organisation: sfa_organisation))

    announcement_has_expanded_links(announcement.content_id)
    stub_govuk_taxonomy_matching_published_taxons(["aaaa"], ["aaaa"])

    get :show, params: { id: announcement }

    refute_select '.taxonomy-topics .no-content'
    assert_select '.taxonomy-topics .content li', "Education, Training and Skills"
    assert_select '.taxonomy-topics .content li', "Primary Education"
  end

private

  def announcement_has_no_expanded_links(content_id)
    publishing_api_has_expanded_links(
      content_id:  content_id,
      expanded_links:  {}
    )
  end

  def announcement_has_expanded_links(content_id)
    publishing_api_has_expanded_links(
      content_id:  content_id,
      expanded_links:  {
        "taxons" => [
          {
            "title" => "Primary Education",
            "content_id" => "aaaa",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "Education, Training and Skills",
                  "content_id" => "bbbb",
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )
  end
end
