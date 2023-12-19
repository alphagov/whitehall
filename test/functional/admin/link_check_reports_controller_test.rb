require "test_helper"
require "gds_api/test_helpers/link_checker_api"

class Admin::LinkCheckReportsControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::LinkCheckerApi

  setup do
    login_as :writer
    @publication = create(:publication, body: "[link](http://www.example.com)")
    Rails.backtrace_cleaner.remove_silencers!

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
    assert @publication.link_check_reports.last
  end

  test "POST :create JSON format creates and renders json template" do
    post :create, params: { edition_id: @publication.id }, format: :json
    assert_template :show
    assert @publication.link_check_reports.last
  end

  test "GET :show redirects back to the edition" do
    link_check_report = create(:link_checker_api_report, link_reportable: @publication)
    get :show, params: { id: link_check_report, edition_id: @publication }
    assert_redirected_to admin_publication_url(@publication)
  end

  test "GET :show JSON format renders JSON template" do
    link_check_report = create(:link_checker_api_report, link_reportable: @publication)
    get :show, params: { id: link_check_report, edition_id: @publication }, format: :json
    assert_template :show
  end
end
