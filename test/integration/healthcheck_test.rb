require "test_helper"

class HealthcheckTest < ActionDispatch::IntegrationTest
  include SidekiqTestHelpers

  def json_response
    JSON.parse(response.body)
  end

  test "GET /healthcheck returns success on request" do
    get "/healthcheck"
    assert_response :success
  end

  test "GET /healthcheck includes an OK health check status when scheduled queue matches number of scheduled editions" do
    with_real_sidekiq do
      ScheduledPublishingWorker.queue(create(:scheduled_edition))

      get "/healthcheck"
      assert_equal "ok", json_response["status"]
      assert_equal "ok", json_response["checks"]["scheduled_queue"]["status"]
    end
  end

  test "GET /healthcheck includes WARNING health check status when scheduled queue does not match the number of scheduled editions" do
    with_real_sidekiq do
      create(:scheduled_edition)

      get "/healthcheck"
      assert_equal "warning", json_response["status"]
      assert_equal "warning", json_response["checks"]["scheduled_queue"]["status"]
      assert_equal "1 scheduled edition(s); 0 job(s) queued", json_response["checks"]["scheduled_queue"]["message"]
    end
  end

  test "GET /healthcheck/overdue shows number of overdue scheduled publications" do
    with_real_sidekiq do
      create(:scheduled_edition, scheduled_publication: 1.day.ago)

      get "/healthcheck/overdue"
      assert_equal 1, json_response["overdue"]
    end
  end

  test "GET /healthcheck/unenqueued_scheduled_editions shows number of scheduled editions without a scheduled job" do
    with_real_sidekiq do
      create(:scheduled_edition)

      get "/healthcheck/unenqueued_scheduled_editions"
      assert_equal 1, json_response["unenqueued_scheduled_editions"]
    end
  end
end
