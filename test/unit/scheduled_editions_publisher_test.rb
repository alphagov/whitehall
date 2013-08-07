require 'test_helper'

class ScheduledEditionsPublisherTest < ActiveSupport::TestCase
  setup { @robot = create(:scheduled_publishing_robot) }

  test 'raises an exception if initialised without an AR Relation' do
    exception = assert_raise ArgumentError do
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
    publisher.expects(:log).with("Edition (#{stubbed_edition.id}) successfully published at #{Time.zone.now}")
    stats_collector = stub_everything("stats_collector")
    stats_collector.expects(:increment).with('scheduled_publishing.published').once

    with_service(:stats_collector, stats_collector) do
      publisher.publish_edition!(stubbed_edition)
    end
  end

  test '#publish_edition! recovers from exceptions and logs the failure' do
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    EditionPublishingWorker.any_instance.expects(:perform).raises(EditionPublishingWorker::ScheduledPublishingFailure, 'Some failure message')
    publisher.expects(:log).with("WARNING: Edition (#{stubbed_edition.id}) failed to publish: Some failure message")
    publisher.publish_edition!(stubbed_edition)
  end

  test '#publish_edition! waits until the publication time before publishing' do
    Whitehall::Wait.expects(:sleep).with(2).returns(2)
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.publish_edition!(stubbed_edition(2.seconds.from_now))
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
    edition1 = stubbed_edition
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.stubs(editions: [edition1])
    publisher.expects(:publish_edition!).with(edition1).twice
    publisher.stubs(:unpublished_editions_remaining?).returns(true, true, true, false)
    publisher.publish_all!
  end

  test '#publish_all! will give up after 5 attempts' do
    edition1 = stubbed_edition
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.stubs(editions: [edition1])
    publisher.expects(:publish_edition!).with(edition1).times(5)
    publisher.stubs(unpublished_editions_remaining?: true)

    assert_raise ScheduledEditionsPublisher::PublishingFailure do
      publisher.publish_all!
    end
  end

  test 'includes the log output and ids of editions not published with the exception raised when publishing fails' do
    edition = stubbed_edition
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.stubs(editions: [edition], log_cache: 'Log output')
    publisher.stubs(unpublished_editions_remaining?: true)

    exception = assert_raise ScheduledEditionsPublisher::PublishingFailure do
      publisher.publish_all!
    end

    assert_equal "Log output", exception.message
    assert_equal [edition.id], exception.unpublished_edition_ids
  end

  test '#log_cache returns everything that has been sent to #log' do
    publisher = ScheduledEditionsPublisher.new(stubbed_scope)
    publisher.log('line 1')
    publisher.log('line 2')
    publisher.log('line 3')

    assert_equal "line 1\nline 2\nline 3\n", publisher.log_cache
  end

  private

  def stubbed_scope(editions=nil)
    Edition.scoped
  end

  def stubbed_edition(publication_time=nil)
    stub('edition', id: 123, title: 'Edition title', scheduled_publication: (publication_time || 1.day.ago))
  end

  def publishing_robot
    @robot
  end
end
