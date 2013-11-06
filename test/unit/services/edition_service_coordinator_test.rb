require 'test_helper'

class EditionServiceCoordinatorTest < ActiveSupport::TestCase
  setup do
    @service_coordinator = EditionServiceCoordinator.new
  end

  test "prepares an EditionPublisher with it's notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    publisher = @service_coordinator.publisher(edition, options)

    assert publisher.is_a?(EditionPublisher)
    assert_equal edition, publisher.edition
    assert_equal options, publisher.options
    assert_equal @service_coordinator, publisher.notifier
  end

  test "prepares an EditionForcePublisher with it's notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    publisher = @service_coordinator.force_publisher(edition, options)

    assert publisher.is_a?(EditionForcePublisher)
    assert_equal edition, publisher.edition
    assert_equal options, publisher.options
    assert_equal @service_coordinator, publisher.notifier
  end

  test "prepares an EditionUnpublisher with it's notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    publisher = @service_coordinator.unpublisher(edition, options)

    assert publisher.is_a?(EditionUnpublisher)
    assert_equal edition, publisher.edition
    assert_equal options, publisher.options
    assert_equal @service_coordinator, publisher.notifier
  end

  test "prepares an EditionArchiver with it's notifier" do
    edition = stub(:edition)
    options = { one: 1, two: 2 }
    publisher = @service_coordinator.archiver(edition, options)

    assert publisher.is_a?(EditionArchiver)
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

    assert_equal [['1'], ['a.1'], ['1.a']], events
  end
end
