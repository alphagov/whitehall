require "test_helper"

class Admin::RepublishingControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
    create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
  end

  should_be_an_admin_controller

  view_test "GDS Admin users should be able to GET :index and see links to republishable content" do
    get :index

    assert_select ".govuk-table:nth-of-type(1) .govuk-table__cell:nth-child(1) a[href='https://www.test.gov.uk/government/history/past-prime-ministers']", text: "Past Prime Ministers"
    assert_select ".govuk-table:nth-of-type(1) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/page/past-prime-ministers/confirm']", text: "Republish 'Past Prime Ministers' page"

    assert_select ".govuk-table:nth-of-type(2) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/organisation/find']", text: "Republish an organisation"

    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :index" do
    login_as :writer

    get :index
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_page with a republishable page slug" do
    get :confirm_page, params: { page_slug: "past-prime-ministers" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_page with an unregistered page slug" do
    get :confirm_page, params: { page_slug: "not-republishable" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to GET :confirm_page" do
    login_as :writer

    get :confirm_page, params: { page_slug: "past-prime-ministers" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_page with a republishable page slug" do
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HistoricalAccountsIndexPresenter").once

    post :republish_page, params: { page_slug: "past-prime-ministers" }

    assert_redirected_to admin_republishing_index_path
    assert_equal "'Past Prime Ministers' page has been scheduled for republishing", flash[:notice]
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish_page with an unregistered page slug" do
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HistoricalAccountsIndexPresenter").never

    get :republish_page, params: { page_slug: "not-republishable" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish_page" do
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HistoricalAccountsIndexPresenter").never

    login_as :writer

    post :republish_page, params: { page_slug: "past-prime-ministers" }
    assert_response :forbidden
  end

  view_test "GDS Admin users should be able to GET :find_organisation" do
    get :find_organisation

    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :find_organisation" do
    login_as :writer

    get :find_organisation
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :search_organisation with an existing organisation slug" do
    create(:organisation, slug: "an-existing-organisation")

    post :search_organisation, params: { organisation_slug: "an-existing-organisation" }

    assert_redirected_to admin_republishing_organisation_confirm_path("an-existing-organisation")
  end

  test "GDS Admin users should be redirected back to :find_organisation when trying to POST :search_organisation with a nonexistent organisation slug" do
    get :search_organisation, params: { organisation_slug: "not-an-existing-organisation" }

    assert_redirected_to admin_republishing_organisation_find_path
    assert_equal "Organisation with slug 'not-an-existing-organisation' not found", flash[:alert]
  end

  test "Non-GDS Admin users should not be able to POST :search_organisation" do
    create(:organisation, slug: "an-existing-organisation")

    login_as :writer

    post :search_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_organisation with an existing organisation slug" do
    create(:organisation, slug: "an-existing-organisation")

    get :confirm_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_organisation with a nonexistent organisation slug" do
    get :confirm_organisation, params: { organisation_slug: "not-an-existing-organisation" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to GET :confirm_organisation" do
    create(:organisation, slug: "an-existing-organisation")

    login_as :writer

    get :confirm_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_organisation with an existing organisation slug" do
    create(:organisation, slug: "an-existing-organisation", name: "An Existing Organisation")

    Organisation.any_instance.expects(:publish_to_publishing_api).once

    post :republish_organisation, params: { organisation_slug: "an-existing-organisation" }

    assert_redirected_to admin_republishing_index_path
    assert_equal "The 'An Existing Organisation' organisation has been scheduled for republishing", flash[:notice]
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish_organisation with a nonexistent organisation slug" do
    Organisation.any_instance.expects(:publish_to_publishing_api).never

    get :republish_organisation, params: { organisation_slug: "not-an-existing-organisation" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish_organisation" do
    create(:organisation, slug: "an-existing-organisation", name: "An Existing Organisation")

    Organisation.any_instance.expects(:publish_to_publishing_api).never

    login_as :writer

    post :republish_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :forbidden
  end
end
