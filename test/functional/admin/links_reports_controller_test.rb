require 'test_helper'

class Admin::LinksReportsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @publication = create(:publication)
    Rails.backtrace_cleaner.remove_silencers!
  end

  should_be_an_admin_controller

  test "AJAX POST :create saves a LinksReport and queues it for processing" do
    Sidekiq::Testing.fake! do
      post :create, params: { links_report: {}, edition_id: @publication.id }, xhr: true

      assert_response :success
      assert_template :create

      assert links_report = @publication.links_reports.last
      job = LinksReportWorker.jobs.last
      assert_equal links_report.id, job['args'].first
    end
  end

  test "POST :create queues a LinksReport and redirects back to the edition" do
    Sidekiq::Testing.fake! do
      post :create, params: { edition_id: @publication.id }

      assert_redirected_to admin_publication_url(@publication)

      assert links_report = @publication.links_reports.last
      job = LinksReportWorker.jobs.last
      assert_equal links_report.id, job['args'].first
    end
  end

  test "AJAX GET :show renders assigns the LinksReport and renders the template" do
    links_report = create(:links_report, link_reportable: @publication)
    get :show, params: { id: links_report, edition_id: @publication }, xhr: true

    assert_response :success
    assert_template :show

    assert_equal links_report, assigns(:links_report)
  end

  test "GET :show redirects back to the edition" do
    links_report = create(:links_report, link_reportable: @publication)
    get :show, params: { id: links_report, edition_id: @publication }

    assert_redirected_to admin_publication_url(@publication)
  end
end
