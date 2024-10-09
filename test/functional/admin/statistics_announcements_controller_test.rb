require "test_helper"

class Admin::StatisticsAnnouncementsControllerTest < ActionController::TestCase
  include TaxonomyHelper

  setup do
    @organisation = create(:organisation)
    @user = login_as :gds_editor, @organisation
    stub_taxonomy_with_world_taxons
  end

  # ==== GET :index ====
  test "GET :index defaults to future-dated announcements by the current user's organisation" do
    @future_announcement = create(
      :statistics_announcement,
      organisation_ids: [@organisation.id],
      statistics_announcement_dates: [create(:statistics_announcement_date, release_date: 1.week.from_now)],
    )
    @past_announcement = create(
      :statistics_announcement,
      organisation_ids: [@organisation.id],
      statistics_announcement_dates: [create(:statistics_announcement_date, release_date: 1.day.ago)],
    )
    @other_announcement = create(:statistics_announcement)

    get :index

    assert_equal [@future_announcement], assigns(:statistics_announcements)
  end

  test "GET :index handles users without an organisation" do
    login_as :gds_editor
    get :index

    assert_response :success
  end

  # ==== GET :new ====
  view_test "GET :new renders a new announcement form" do
    get :new

    assert_response :success
    assert_select "input[name='statistics_announcement[title]']"
    refute_select "#statistics_announcement_publication_type_id > fieldset > .govuk-hint"
  end

  # ==== POST :create ====
  test "POST :create saves the announcement to the database and redirects to the dashboard with provisional date" do
    post :create,
         params: {
           statistics_announcement: {
             title: "Beard stats 2014",
             summary: "Summary text",
             publication_type_id: PublicationType::OfficialStatistics.id,
             organisation_ids: [@organisation.id],
             statistics_announcement_dates_attributes: {
               release_date: 1.year.from_now,
               precision: StatisticsAnnouncementDate::PRECISION[:one_month],
             },
           },
         }

    assert_response :redirect
    assert announcement = StatisticsAnnouncement.last
    assert_equal "Beard stats 2014", announcement.title
    assert_includes announcement.organisations, @organisation
    assert_equal @user, announcement.creator
    assert_equal "November 2012", announcement.display_date
    assert_equal false, announcement.confirmed?
    assert_equal @user, announcement.current_release_date.creator
  end

  test "POST :create saves the announcement to the database and redirects to the dashboard with confirmed date" do
    post :create,
         params: {
           statistics_announcement: {
             title: "Beard stats 2014",
             summary: "Summary text",
             publication_type_id: PublicationType::OfficialStatistics.id,
             organisation_ids: [@organisation.id],
             statistics_announcement_dates_attributes: {
               release_date: 1.year.from_now,
               precision: "exact_confirmed",
             },
           },
         }

    assert_response :redirect
    assert announcement = StatisticsAnnouncement.last
    assert_equal "Beard stats 2014", announcement.title
    assert_includes announcement.organisations, @organisation
    assert_equal @user, announcement.creator
    assert_equal "11 November 2012 11:11am", announcement.display_date
    assert_equal true, announcement.confirmed?
    assert_equal @user, announcement.current_release_date.creator
  end

  view_test "POST :create re-renders the form if the announcement is invalid" do
    post :create, params: { statistics_announcement: { title: "", summary: "Summary text" } }

    assert_response :success
    assert_select "ul.govuk-error-summary__list a", text: "Title can't be blank"
    assert_not StatisticsAnnouncement.any?
  end

  # ==== GET :show ====
  view_test "GET :show renders the details of the announcement" do
    announcement = create(:statistics_announcement)
    stub_publishing_api_expanded_links_with_taxons(announcement.content_id, [])
    get :show, params: { id: announcement }

    assert_response :success
    assert_select "h1.govuk-heading-xl", text: announcement.title
  end

  view_test "GET :show renders when announcement is not tagged to the new taxonomy" do
    sfa_organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")

    announcement = create(
      :statistics_announcement,
      organisations: [sfa_organisation],
    )

    login_as(:user)

    announcement_has_no_expanded_links(announcement.content_id)
    get :show, params: { id: announcement }

    assert_select ".govuk-warning-text", /You need to add topic tags before you can publish this document./
    refute_select ".govuk-breadcrumbs__list"
  end

  view_test "GET :show renders when announcement is tagged to the new taxonomy" do
    sfa_organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")

    announcement = create(
      :statistics_announcement,
      organisations: [sfa_organisation],
    )

    login_as(:user)

    announcement_has_expanded_links(announcement.content_id)

    get :show, params: { id: announcement }

    refute_select ".govuk-warning-text"
    assert_select ".govuk-breadcrumbs__list-item", "Education, Training and Skills"
    assert_select ".govuk-breadcrumbs__list-item", "Primary Education"
  end

  view_test "GET :show show a link to tag to the new taxonomy" do
    dfe_organisation = create(:organisation, content_id: "ebd15ade-73b2-4eaf-b1c3-43034a42eb37")

    announcement = create(
      :statistics_announcement,
      organisations: [dfe_organisation],
    )

    login_as(:user)

    announcement_has_no_expanded_links(announcement.content_id)
    get :show, params: { id: announcement }

    assert_select "a[href='#{edit_admin_statistics_announcement_tags_path(announcement.id)}']", "Add tags"
  end

  # ==== GET :edit ====
  view_test "GET :edit renders the edit form for the  announcement" do
    announcement = create(:statistics_announcement)
    get :edit, params: { id: announcement.id }

    assert_response :success
    assert_select "input[name='statistics_announcement[title]'][value='#{announcement.title}']"
    assert_select "#statistics_announcement_publication_type_id .govuk-hint", "Please note that changing the statistics type will also automatically update the type of the connected document."
  end

  # ==== PUT :update ====
  test "PUT :update saves changes to the announcement" do
    announcement = create(:statistics_announcement)
    put :update, params: { id: announcement.id, statistics_announcement: { title: "New announcement title" } }

    assert_response :redirect
    assert_equal "New announcement title", announcement.reload.title
  end

  view_test "PUT :update re-renders edit form if changes are not valid" do
    announcement = create(:statistics_announcement)
    put :update, params: { id: announcement.id, statistics_announcement: { title: "" } }

    assert_response :success
    assert_select "ul.govuk-error-summary__list a", text: "Title can't be blank"
  end

  test "PUT :update should update connected draft publication in Publishing API if announcement publication type has been changed" do
    national_statistics = create(:draft_national_statistics, lead_organisations: [@organisation])
    announcement = create(
      :statistics_announcement,
      publication_type_id: PublicationType::NationalStatistics.id,
      publication: national_statistics,
      organisation_ids: [@organisation.id],
    )

    announcement_presenter = PublishingApiPresenters.presenter_for(announcement)
    announcement_content = announcement_presenter.content.merge(
      title: "New title",
      public_updated_at: Time.zone.now.as_json,
    )

    WebMock.reset!

    expected_requests = [
      stub_publishing_api_patch_links(announcement.content_id, links: announcement_presenter.links),
      stub_publishing_api_put_content(announcement.content_id, with_locale(:en) { announcement_content }),
      stub_publishing_api_publish(announcement.content_id, locale: "en", update_type: nil),
    ]

    put :update, params: {
      id: announcement.id,
      statistics_announcement: {
        title: "New title",
        publication_type_id: PublicationType::NationalStatistics.id,
      },
    }

    assert_all_requested(expected_requests)
  end

  test "PUT :update should not update connected draft publication in Publishing API if announcement publication type has not been changed" do
    national_statistics = create(:draft_national_statistics, lead_organisations: [@organisation])
    announcement = create(
      :statistics_announcement,
      publication_type_id: PublicationType::NationalStatistics.id,
      publication: national_statistics,
      organisation_ids: [@organisation.id],
    )

    publication_presenter = PublishingApiPresenters.presenter_for(national_statistics)
    publication_content = publication_presenter.content.merge(
      document_type: "official_statistics",
    )
    html_attachment_presenter = PublishingApiPresenters.presenter_for(national_statistics.attachments.first)

    announcement_presenter = PublishingApiPresenters.presenter_for(announcement)
    announcement_details = announcement_presenter.content[:details].merge(
      format_sub_type: "official",
    )
    announcement_content = announcement_presenter.content.merge(
      title: "New title",
      document_type: "official_statistics_announcement",
      details: announcement_details,
      public_updated_at: Time.zone.now.as_json,
    )

    WebMock.reset!

    expected_requests = [
      stub_publishing_api_patch_links(publication_presenter.content_id, links: publication_presenter.links),
      stub_publishing_api_put_content(publication_presenter.content_id, with_locale(:en) { publication_content }),
      stub_publishing_api_put_content(html_attachment_presenter.content_id, html_attachment_presenter.content),
      stub_publishing_api_patch_links(announcement.content_id, links: announcement_presenter.links),
      stub_publishing_api_put_content(announcement.content_id, with_locale(:en) { announcement_content }),
      stub_publishing_api_publish(announcement.content_id, locale: "en", update_type: nil),
    ]

    put :update, params: {
      id: announcement.id,
      statistics_announcement: {
        title: "New title",
        publication_type_id: PublicationType::OfficialStatistics.id,
      },
    }

    assert_all_requested(expected_requests)
  end

  # ==== POST :publish_cancellation ====
  test "POST :publish_cancellation cancels the announcement" do
    announcement = create(:statistics_announcement)
    post :publish_cancellation,
         params: {
           id: announcement.id,
           statistics_announcement: { cancellation_reason: "Reason" },
         }

    assert_redirected_to [:admin, announcement]
    assert announcement.reload.cancelled?
    assert_equal "Reason", announcement.cancellation_reason
    assert_equal Time.zone.now, announcement.cancelled_at
  end

  test "POST :publish_cancellation cannot cancel cancelled announcements" do
    announcement = create(:cancelled_statistics_announcement)

    get :cancel, params: { id: announcement }
    assert_redirected_to [:admin, announcement]

    post :publish_cancellation,
         params: {
           id: announcement.id,
           statistics_announcement: { cancellation_reason: "Reason" },
         }
    assert_redirected_to [:admin, announcement]
  end

  view_test "POST :publish_cancellation re-renders cancellation form if changes are not valid" do
    announcement = create(:statistics_announcement)
    post :publish_cancellation,
         params: {
           id: announcement.id,
           statistics_announcement: { cancellation_reason: "" },
         }

    assert_response :success
    assert_template :cancel
    assert_select "ul.govuk-error-summary__list a", text: "Cancellation reason must be provided when cancelling an announcement"
  end

  # ==== PATCH :update_cancel_reason ====
  test "PATCH :update_cancel_reason updates the cancellation message" do
    announcement = create(:cancelled_statistics_announcement)
    patch :update_cancel_reason,
          params: {
            id: announcement.id,
            statistics_announcement: { cancellation_reason: "Another reason" },
          }

    assert_redirected_to [:admin, announcement]
    assert_equal "Another reason", announcement.reload.cancellation_reason
    assert_equal Time.zone.now, announcement.cancelled_at
  end

  view_test "PATCH :update_cancel_reason re-renders cancel_reason form if changes are not valid" do
    announcement = create(:cancelled_statistics_announcement)
    patch :update_cancel_reason,
          params: {
            id: announcement.id,
            statistics_announcement: { cancellation_reason: "" },
          }

    assert_response :success
    assert_template :cancel_reason
    assert_select "ul.govuk-error-summary__list a", text: "Cancellation reason must be provided when cancelling an announcement"
  end

private

  def announcement_has_no_expanded_links(content_id)
    stub_publishing_api_has_expanded_links(
      {
        content_id:,
        expanded_links: {},
      },
    )
  end

  def announcement_has_expanded_links(content_id)
    stub_publishing_api_has_expanded_links(
      {
        content_id:,
        expanded_links: {
          "taxons" => [
            {
              "title" => "Primary Education",
              "content_id" => "aaaa",
              "base_path" => "i-am-a-taxon",
              "details" => { "visible_to_departmental_editors" => true },
              "links" => {
                "parent_taxons" => [
                  {
                    "title" => "Education, Training and Skills",
                    "content_id" => "bbbb",
                    "base_path" => "i-am-a-parent-taxon",
                    "details" => { "visible_to_departmental_editors" => true },
                    "links" => {},
                  },
                ],
              },
            },
          ],
        },
      },
    )
  end
end
