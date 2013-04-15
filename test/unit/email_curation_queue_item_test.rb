require 'test_helper'

class EmailCurationQueueItemTest < ActiveSupport::TestCase
  test 'is invalid without an edition' do
    refute build(:email_curation_queue_item, edition: nil).valid?
  end

  test 'is invalid without a title' do
    refute build(:email_curation_queue_item, title: nil).valid?
  end

  test 'is invalid without a summary' do
    refute build(:email_curation_queue_item, summary: nil).valid?
  end

  test 'is invalid without a notification date' do
    refute build(:email_curation_queue_item, notification_date: nil).valid?
  end
end
