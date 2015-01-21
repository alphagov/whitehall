require 'test_helper'

class Admin::LinksReportsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @policy = create(:policy)
    Rails.backtrace_cleaner.remove_silencers!
  end

  should_be_an_admin_controller

  test "AJAX POST :create saves a LinksReport and queues it for processing" do
    Sidekiq::Testing.fake! do
      xhr :post, :create, links_report: {}, edition_id: @policy.id

      assert_response :success
      assert_template :create

      assert links_report = @policy.links_reports.last
      job = LinksReportWorker.jobs.last
      assert_equal [links_report.id], job['args']
    end
  end

  test "POST :create queues a LinksReport and redirects back to the edition" do
    Sidekiq::Testing.fake! do
      post :create, edition_id: @policy.id

      assert_redirected_to admin_policy_url(@policy)

      assert links_report = @policy.links_reports.last
      job = LinksReportWorker.jobs.last
      assert_equal [links_report.id], job['args']
    end
  end

  test "AJAX GET :show renders assigns the LinksReport and renders the template" do
    links_report = create(:links_report, link_reportable: @policy)
    xhr :get, :show, id: links_report, edition_id: @policy

    assert_response :success
    assert_template :show

    assert_equal links_report, assigns(:links_report)
  end

  test "GET :show redirects back to the edition" do
    links_report = create(:links_report, link_reportable: @policy)
    get :show, id: links_report, edition_id: @policy

    assert_redirected_to admin_policy_url(@policy)
  end
end
