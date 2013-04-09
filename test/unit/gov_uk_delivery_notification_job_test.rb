require 'test_helper'

class GovUkDeliveryNotificationJobTest < ActiveSupport::TestCase

  test '#perform sends a notification for the edition via the gov uk delivery client' do
    policy = create(:policy)
    Policy.any_instance.stubs(govuk_delivery_email_body: 'email body')
    Whitehall.govuk_delivery_client.expects(:notify).with(policy.govuk_delivery_tags, policy.title, 'email body')

    GovUkDeliveryNotificationJob.new(policy.id).perform
  end
end
