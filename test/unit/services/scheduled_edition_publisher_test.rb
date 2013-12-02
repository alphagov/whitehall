require 'test_helper'

class ScheduledEditionPublisherTest < ActiveSupport::TestCase
  test '#perform! with a submitted edition refuses to publish' do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    publisher = ScheduledEditionPublisher.new(edition)

    refute publisher.perform!
    refute edition.published?

    expected_reason = 'Only scheduled editions can be published with ScheduledEditionPublisher'
    assert_equal expected_reason, publisher.failure_reason
  end

  test '#perform! with a future-scheduled edition refuses to publish' do
    edition = create(:scheduled_edition)
    publisher = ScheduledEditionPublisher.new(edition)

    refute publisher.perform!
    refute edition.published?

    expected_reason = "This edition is scheduled for publication on #{edition.scheduled_publication.to_s}, and may not be published before"
    assert_equal expected_reason, publisher.failure_reason
  end

  test '#perform! with a scheduled edition publishes' do
    edition = create(:scheduled_edition, scheduled_publication: 1.hour.ago)
    publisher = ScheduledEditionPublisher.new(edition)

    assert publisher.perform!
    assert edition.published?
  end

  test '#perform! with an invalid scheduled edition publishes' do
    edition = create(:scheduled_edition, scheduled_publication: 1.hour.ago)
    edition.update_attribute(:body, nil)
    publisher = ScheduledEditionPublisher.new(edition)

    assert publisher.perform!
    assert edition.published?
  end
end
