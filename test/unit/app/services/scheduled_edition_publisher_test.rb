require "test_helper"

class ScheduledEditionPublisherTest < ActiveSupport::TestCase
  test "#perform! with a submitted edition refuses to publish" do
    edition = create(:submitted_edition, scheduled_publication: 1.day.from_now)
    publisher = ScheduledEditionPublisher.new(edition)

    assert_not publisher.perform!
    assert_not edition.published?

    expected_reason = "Only scheduled editions can be published with ScheduledEditionPublisher"
    assert_equal expected_reason, publisher.failure_reason
  end

  test "#perform! with a future-scheduled edition refuses to publish" do
    edition = create(:scheduled_edition)
    publisher = ScheduledEditionPublisher.new(edition)

    assert_not publisher.perform!
    assert_not edition.published?

    expected_reason = "This edition is scheduled for publication on #{edition.scheduled_publication}, and may not be published before"
    assert_equal expected_reason, publisher.failure_reason
  end

  test "#perform! with a scheduled edition publishes" do
    edition = create(:scheduled_edition, scheduled_publication: 1.hour.ago)
    publisher = ScheduledEditionPublisher.new(edition)

    assert publisher.perform!
    assert edition.published?
  end

  test "#perform! with an invalid scheduled edition publishes" do
    edition = create(:scheduled_edition, scheduled_publication: 1.hour.ago)
    edition.body = nil
    edition.save!(validate: false)
    publisher = ScheduledEditionPublisher.new(edition)

    assert publisher.perform!
    assert edition.published?
  end

  test "#perform! clears the edition's auth_bypass_id" do
    edition = create(:scheduled_edition, :with_auth_bypass_id, scheduled_publication: 1.hour.ago)
    publisher = ScheduledEditionPublisher.new(edition)

    assert publisher.perform!
    assert_nil edition.reload.auth_bypass_id
  end

  test "#perform! propagates the cleared auth_bypass_id to assets when the edition previously had a token" do
    edition = create(:scheduled_edition, :with_auth_bypass_id, scheduled_publication: 1.hour.ago)
    publisher = ScheduledEditionPublisher.new(edition)

    EditionAuthBypassAssetPropagator.any_instance.expects(:propagate).once

    publisher.perform!
  end
end
