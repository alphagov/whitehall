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
