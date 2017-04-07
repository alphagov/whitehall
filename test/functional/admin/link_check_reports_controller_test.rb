require 'test_helper'
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

  test "AJAX POST :create saves a LinkCheckReport" do
    xhr :post, :create, edition_id: @publication.id

    assert_response :success
    assert_template :create

    assert link_check_report = @publication.link_check_reports.last
  end

  test "POST :create saves a LinksReport and redirects back to the edition" do
    post :create, edition_id: @publication.id

    assert_redirected_to admin_publication_url(@publication)

    assert link_check_report = @publication.link_check_reports.last
  end

  test "AJAX GET :show renders assigns the LinksReport and renders the template" do
    link_check_report = create(:link_checker_api_report, link_reportable: @publication)
    xhr :get, :show, id: link_check_report, edition_id: @publication

    assert_response :success
    assert_template :show

    assert_equal link_check_report, assigns(:report)
  end

  test "GET :show redirects back to the edition" do
    link_check_report = create(:link_checker_api_report, link_reportable: @publication)
    get :show, id: link_check_report, edition_id: @publication

    assert_redirected_to admin_publication_url(@publication)
  end
end
