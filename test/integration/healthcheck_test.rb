require "test_helper"

class HealthcheckTest < ActionDispatch::IntegrationTest
  def json_response
    JSON.parse(response.body)
  end

  test "GET /healthcheck/overdue shows number of overdue scheduled publications" do
    create(:scheduled_edition, scheduled_publication: 1.day.ago)

    get "/healthcheck/overdue"
    assert_equal 1, json_response["overdue"]
  end

  test "GET /healthcheck/unenqueued_scheduled_editions shows number of scheduled editions without a scheduled job" do
    ScheduledPublishingJob.stubs(:queue_size).returns(1)
    create_list(:scheduled_edition, 2)

    get "/healthcheck/unenqueued_scheduled_editions"
    assert_equal 1, json_response["unenqueued_scheduled_editions"]
  end
end
