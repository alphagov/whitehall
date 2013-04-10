# encoding: utf-8
require 'test_helper'

class GovUkDeliveryNotificationJobTest < ActiveSupport::TestCase

  setup do
    @policy = create(:policy)
    @policy.first_published_at = Time.zone.now
    @policy.major_change_published_at = Time.zone.now
    @job = GovUkDeliveryNotificationJob.new(@policy.id)
  end

  test '#perform sends a notification for the edition via the gov uk delivery client' do
    @job.stubs(email_body: 'email body')
    Whitehall.govuk_delivery_client.expects(:notify).with(@policy.govuk_delivery_tags, @policy.title, 'email body')
    @job.perform
  end

  test '#perform handles 400 errors (i.e. no subscribers) gracefully' do
    Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::HTTPErrorResponse, 400)

    assert_nothing_raised { @job.perform }
  end

  test '#perform lets non-400 exceptions bubble up' do
    Whitehall.govuk_delivery_client.expects(:notify).raises(GdsApi::HTTPErrorResponse, 500)

    exception = assert_raises(GdsApi::HTTPErrorResponse) { @job.perform }
    assert_equal 500, exception.code
  end

  test '#email_body generates a utf-8 encoded body' do
    @policy.update_attribute(:title, "Café".encode("UTF-8"))
    body = GovUkDeliveryNotificationJob.new(@policy.id).email_body

    assert_includes body, @policy.title
    assert_equal 'UTF-8', body.encoding.name
  end

  test '#email_body should link to full URL in email' do
    assert_match /#{Whitehall.public_host}/, @job.email_body
  end

  test '#email_body html escapes html characters in the title and summary' do
    @policy.update_attributes(title: 'Beards & Facial Hair', summary: 'Keep your beard "tip-top"!')

    assert_match %r(Beards &amp; Facial Hair), @job.email_body
    assert_match %r(Keep your beard &quot;tip-top&quot;!), @job.email_body
  end
end
