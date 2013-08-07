require 'test_helper'

class GovUkDeliveryNotificationJobTest < ActiveSupport::TestCase
  test '#perform sends a notification via the govuk delivery client' do
    Whitehall.govuk_delivery_client.expects(:notify).with(notifier.tags, notifier.display_title, notifier.email_body)
    job.perform
  end

  test '#perform swallows API 400 errors (i.e. no subscribers)' do
    Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::HTTPErrorResponse, 400)
    assert_nothing_raised { job.perform }
  end

  test '#perform does not rescue non-400 API errors' do
    Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::HTTPErrorResponse, 500)
    exception = assert_raise(GdsApi::HTTPErrorResponse) { job.perform }
    assert_equal 500, exception.code
  end

  test '#perform does not rescue any other non-API errors' do
    Whitehall.govuk_delivery_client.expects(:notify).raises(RuntimeError)
    exception = assert_raise(RuntimeError) { job.perform }
  end

  private

  def notifier
    @notifier ||= stub('notifier', tags: 'tags', display_title: 'title', email_body: 'email body')
  end

  def job
    @job ||= GovUkDeliveryNotificationJob.new(notifier)
  end
end
