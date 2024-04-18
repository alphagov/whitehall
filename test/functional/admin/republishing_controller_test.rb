require "test_helper"

class Admin::RepublishingControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
    create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
  end

  should_be_an_admin_controller

  view_test "GDS Admin users should be able to acess the GET :index and see links to republishable pages" do
    get :index

    assert_select ".govuk-table__cell:nth-child(1) a[href='https://www.test.gov.uk/government/history/past-prime-ministers']", text: "Past Prime Ministers"
    assert_select ".govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/past-prime-ministers/confirm']", text: "Republish 'Past Prime Ministers' page"
    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to access the GET :index" do
    login_as :writer

    get :index
    assert_response :forbidden
  end

  test "GDS Admin users should be able to access GET :confirm_page with a republishable page slug" do
    get :confirm_page, params: { page_slug: "past-prime-ministers" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_page with an unregistered page slug" do
    get :confirm_page, params: { page_slug: "not-republishable" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to access GET :confirm_page" do
    login_as :writer

    get :confirm_page, params: { page_slug: "past-prime-ministers" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to trigger the PresentPageToPublishingWorker job with the HistoricalAccountsIndexPresenter" do
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HistoricalAccountsIndexPresenter").once

    post :republish_past_prime_ministers_index

    assert_redirected_to admin_republishing_index_path
    assert_equal "'Past Prime Ministers' page has been scheduled for republishing", flash[:notice]
  end

  test "Non-GDS Admin users should not be able to republish the page" do
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HistoricalAccountsIndexPresenter").never

    login_as :writer

    post :republish_past_prime_ministers_index
    assert_response :forbidden
  end
end
