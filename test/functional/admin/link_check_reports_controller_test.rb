require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class Admin::LinkCheckReportsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  setup do
    login_as :writer
    @publication = create(:publication, body: "[link](http://www.example.com)")

    link_checker_endpoint = "#{Plek.find('link-checker-api')}/batch"
    body = link_checker_api_batch_report_hash(
      id: 5,
      links: [{ uri: "http://www.example.com" }],
    )
    stub_request(:post, %r{\A#{link_checker_endpoint}})
      .to_return(
        body: body.to_json,
        status: 202,
        headers: { "Content-Type": "application/json" },
      )
  end

  should_be_an_admin_controller

  test "POST :create saves a LinkCheckReport and redirects back to the edition" do
    post :create, params: { edition_id: @publication.id }
    assert_redirected_to admin_publication_url(@publication)
    assert @publication.link_check_report
  end

  test "POST :create JSON format creates and renders json template" do
    post :create, params: { edition_id: @publication.id }, format: :json
    assert_template :show
    assert @publication.link_check_report
  end

  test "GET :show redirects back to the edition" do
    link_check_report = create(:link_checker_api_report, edition: @publication)
    get :show, params: { id: link_check_report, edition_id: @publication }
    assert_redirected_to admin_publication_url(@publication)
  end

  test "GET :show JSON format renders JSON template" do
    link_check_report = create(:link_checker_api_report, edition: @publication)
    get :show, params: { id: link_check_report, edition_id: @publication }, format: :json
    assert_template :show
  end

  test "GET :show only finds reports belonging to the edition in the URL" do
    other_publication = create(:publication)
    other_report = create(:link_checker_api_report, edition: other_publication)

    assert_raise(ActiveRecord::RecordNotFound) do
      get :show, params: { id: other_report, edition_id: @publication }, format: :json
    end
  end

  test "GET :show is forbidden for an access-limited edition the user cannot see" do
    inaccessible = create(:draft_publication, :access_limited_by_organisations, organisations: [create(:organisation)])
    link_check_report = create(:link_checker_api_report, edition: inaccessible)

    get :show, params: { id: link_check_report, edition_id: inaccessible }, format: :json

    assert_response :forbidden
  end

  test "POST :create is forbidden for an access-limited edition the user cannot see" do
    inaccessible = create(:draft_publication, :access_limited_by_organisations, organisations: [create(:organisation)])

    post :create, params: { edition_id: inaccessible }, format: :json

    assert_response :forbidden
    assert_nil inaccessible.reload.link_check_report
  end
end
