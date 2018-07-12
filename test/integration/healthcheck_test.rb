require 'test_helper'

class HealthcheckTest < ActionDispatch::IntegrationTest
  include SidekiqTestHelpers

  def json_response
    JSON.parse(response.body)
  end

  test 'returns success on request' do
    get "/healthcheck"
    assert_response :success
  end

  test 'includes an OK health check status when scheduled queue matches number of scheduled editions' do
    with_real_sidekiq do
      ScheduledPublishingWorker.queue(create(:scheduled_edition))

      get "/healthcheck"
      assert_equal 'ok', json_response['status']
      assert_equal 'ok', json_response['checks']['scheduled_queue']['status']
    end
  end

  test 'includes WARNING health check status when scheduled queue does not match the number of scheduled editions' do
    with_real_sidekiq do
      create(:scheduled_edition)

      get "/healthcheck"
      assert_equal 'warning', json_response['status']
      assert_equal 'warning', json_response['checks']['scheduled_queue']['status']
      assert_equal '1 scheduled edition(s); 0 job(s) queued', json_response['checks']['scheduled_queue']['message']
    end
  end
end
