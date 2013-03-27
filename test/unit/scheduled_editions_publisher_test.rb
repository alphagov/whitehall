require 'test_helper'

class ScheduledEditionsPublisherTest < ActiveSupport::TestCase
  setup { @robot = create(:scheduled_publishing_robot) }

  test 'raises an exception if initialised without an AR Relation' do
    exception = assert_raises ArgumentError do
      ScheduledEditionsPublisher.new([])
    end
    assert_equal 'editions_scope must be an ActiveRecord::Relation', exception.message
  end

  test '#publishing_robot returns the publishing robot' do
    assert_equal publishing_robot, ScheduledEditionsPublisher.new(stubbed_scope).publishing_robot
  end

  test '#editions returns the exploded editions from a scope' do
    edition1 = create(:edition, :scheduled, scheduled_publication: Time.zone.now)
    edition2 = create(:edition, :scheduled, scheduled_publication: Time.zone.now)
    edition3 = create(:edition)
    publisher = ScheduledEditionsPublisher.new(Edition.where(state: 'scheduled'))

    assert_equal [edition1, edition2], publisher.editions
  end

  test '#publish_edition! publishes the edition using the publishing robot and logs the result' do
    EditionPublishingWorker.any_instance.expects(:perform).with(stubbed_edition.id, publishing_robot.id)
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.expects(:log).with("Edition (#{stubbed_edition.id}) successfully published")
    stats_collector = stub_everything("stats_collector")
    stats_collector.expects(:increment).with('scheduled_publishing.published').once

    with_service(:stats_collector, stats_collector) do
      publisher.publish_edition!(stubbed_edition)
    end
  end

  test '#publish_edition! recovers from exceptions and logs the failure' do
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    EditionPublishingWorker.any_instance.expects(:perform).raises(EditionPublishingWorker::ScheduledPublishingFailure, 'Some failure message')
    publisher.expects(:log).with("Unable to publish edition (#{stubbed_edition.id}): Some failure message")
    publisher.publish_edition!(stubbed_edition)
  end

  test '#publish_edition! waits until the publication time before publishing' do
    Timecop.return
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.publish_edition!(stubbed_edition(1.second.from_now))
    assert Time.zone.now > stubbed_edition.scheduled_publication, '#publish_edition! method did not wait until scheduled_publication time before publishing!'
  end

  test '#publish_all! publishes editions in scope' do
    edition1 = create(:edition, :scheduled, scheduled_publication: Time.zone.now)
    edition2 = create(:edition, :scheduled, scheduled_publication: Time.zone.now)
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.stubs(:unpublished_editions_remaining?).returns(true, false)
    publisher.stubs(editions: [edition1, edition2])
    publisher.expects(:publish_edition!).with(edition1)
    publisher.expects(:publish_edition!).with(edition2)
    publisher.publish_all!
  end

  test '#publish_all! will retry if there are still unpublished editions' do
    edition1 = create(:edition, :scheduled, scheduled_publication: Time.zone.now)
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.stubs(editions: [edition1])
    publisher.expects(:publish_edition!).twice
    publisher.stubs(:unpublished_editions_remaining?).returns(true, true, false)
    publisher.publish_all!
  end

  test '#publish_all! will give up after 5 attempts' do
    edition1 = create(:edition, :scheduled, scheduled_publication: Time.zone.now)
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.stubs(editions: [edition1])
    publisher.expects(:publish_edition!).with(edition1).times(5)
    publisher.stubs(unpublished_editions_remaining?: true)

    assert_raises ScheduledEditionsPublisher::PublishingFailure do
      publisher.publish_all!
    end
  end

  private

  def stubbed_scope(editions=nil)
    Edition.scoped
  end

  def stubbed_edition(publication_time=nil)
    stub('edition', id: 123, scheduled_publication: (publication_time || 1.day.ago))
  end

  def publishing_robot
    @robot
  end
end
