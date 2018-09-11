require 'test_helper'

class EditionServiceCoordinatorTest < ActiveSupport::TestCase
  setup do
    @service_coordinator = EditionServiceCoordinator.new
  end

  test "prepares an EditionPublisher with its notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    publisher = @service_coordinator.publisher(edition, options)

    assert publisher.is_a?(EditionPublisher)
    assert_equal edition, publisher.edition
    assert_equal options, publisher.options
    assert_equal @service_coordinator, publisher.notifier
  end

  test "prepares an EditionForcePublisher with its notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    publisher = @service_coordinator.force_publisher(edition, options)

    assert publisher.is_a?(EditionForcePublisher)
    assert_equal edition, publisher.edition
    assert_equal options, publisher.options
    assert_equal @service_coordinator, publisher.notifier
  end

  test "prepares an EditionScheduler with its notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    scheduler = @service_coordinator.scheduler(edition, options)

    assert scheduler.is_a?(EditionScheduler)
    assert_equal edition, scheduler.edition
    assert_equal options, scheduler.options
    assert_equal @service_coordinator, scheduler.notifier
  end

  test "prepares an EditionForceScheduler with its notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    force_scheduler = @service_coordinator.force_scheduler(edition, options)

    assert force_scheduler.is_a?(EditionForceScheduler)
    assert_equal edition, force_scheduler.edition
    assert_equal options, force_scheduler.options
    assert_equal @service_coordinator, force_scheduler.notifier
  end

  test "prepares an EditionUnscheduler with its notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    unscheduler = @service_coordinator.unscheduler(edition, options)

    assert unscheduler.is_a?(EditionUnscheduler)
    assert_equal edition, unscheduler.edition
    assert_equal options, unscheduler.options
    assert_equal @service_coordinator, unscheduler.notifier
  end

  test "prepares an EditionUnpublisher with its notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    publisher = @service_coordinator.unpublisher(edition, options)

    assert publisher.is_a?(EditionUnpublisher)
    assert_equal edition, publisher.edition
    assert_equal options, publisher.options
    assert_equal @service_coordinator, publisher.notifier
  end

  test "prepares an EditionWithdrawer with its notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    publisher = @service_coordinator.withdrawer(edition, options)

    assert publisher.is_a?(EditionWithdrawer)
    assert_equal edition, publisher.edition
    assert_equal options, publisher.options
    assert_equal @service_coordinator, publisher.notifier
  end

  test "listeners on named events are notified" do
    events = []
    @service_coordinator.subscribe('action1') { |*args| events << args }

    @service_coordinator.publish('action1', :arg1, :arg2)
    @service_coordinator.publish('action2', :arg3)

    assert_equal [['action1', :arg1, :arg2]], events
  end

  test "wildcard listeners receive notifications for all events" do
    events = []
    @service_coordinator.subscribe { |*args| events << args }

    @service_coordinator.publish('action1', :arg1, :arg2)
    @service_coordinator.publish('action2', :arg3)

    assert_equal [['action1', :arg1, :arg2], ['action2', :arg3]], events
  end

  test "listener can subscribe with a pattern" do
    events = []
    @service_coordinator.subscribe(/\d/) { |*args| events << args }

    @service_coordinator.publish '1'
    @service_coordinator.publish 'a.1'
    @service_coordinator.publish '1.a'
    @service_coordinator.publish 'Foo'

    assert_equal [%w[1], ['a.1'], ['1.a']], events
  end
end
