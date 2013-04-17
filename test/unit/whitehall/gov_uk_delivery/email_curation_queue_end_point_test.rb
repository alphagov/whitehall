require 'test_helper'

class Whitehall::GovUkDelivery::EmailCurationQueueEndPointTest < ActiveSupport::TestCase
  def email_curation_queue_notifier_for(edition, notification_date = Time.zone.now)
    Whitehall::GovUkDelivery::EmailCurationQueueEndPoint.new(edition, notification_date)
  end

  test '#notify! constructs a new EmailCurationQueueItem based on the edition' do
    policy = create(:policy, topics: [create(:topic)])
    notifier = email_curation_queue_notifier_for(policy, 1.day.ago)
    EmailCurationQueueItem.expects(:create_from_edition).with(policy, 1.day.ago)

    notifier.notify!
  end
end
