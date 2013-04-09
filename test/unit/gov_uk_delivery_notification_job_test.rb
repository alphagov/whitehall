# encoding: utf-8
require 'test_helper'

class GovUkDeliveryNotificationJobTest < ActiveSupport::TestCase

  test '#perform sends a notification for the edition via the gov uk delivery client' do
    policy = create(:policy)
    job = GovUkDeliveryNotificationJob.new(policy.id)
    job.stubs(email_body: 'email body')
    Whitehall.govuk_delivery_client.expects(:notify).with(policy.govuk_delivery_tags, policy.title, 'email body')

    job.perform
  end

  test '#email_body generates a utf-8 encoded body' do
    publication = create(:news_article, title: "Café".encode("UTF-8"))

    body = GovUkDeliveryNotificationJob.new(publication.id).email_body
    assert_includes body, publication.title
    assert_equal 'UTF-8', body.encoding.name
  end

  test '#email_body should link to full URL in email' do
    publication = create(:publication)
    publication.first_published_at = Time.zone.now
    publication.major_change_published_at = Time.zone.now

    body = GovUkDeliveryNotificationJob.new(publication.id).email_body

    assert_match /#{Whitehall.public_host}/, body
  end
end
