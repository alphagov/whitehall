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

  test 'it can be created from an edition and notification date' do
    edition = create(:edition)
    item = EmailCurationQueueItem.create_from_edition(edition, 1.day.ago)

    assert_equal edition, item.edition
    assert_equal edition.title, item.title
    assert_equal edition.summary, item.summary
    assert_equal 1.day.ago, item.notification_date
    assert item.persisted?
  end
end
