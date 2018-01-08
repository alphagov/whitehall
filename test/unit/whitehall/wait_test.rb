require 'test_helper'

class WaitTest < ActiveSupport::TestCase
  setup do
    # reset global Timecop.freeze call in test_helper
    Timecop.return

    @base_time = Time.zone.now
  end

  test "sleeps for the number of seconds until the timestamp before executing the block" do
    time_state = states('time_state').starts_as('initial')
    Time.zone.stubs(:now).when(time_state.is('initial')).returns(@base_time)
    Time.zone.stubs(:now).when(time_state.is('slept_once')).returns(@base_time + 2.seconds)

    Whitehall::Wait.expects(:sleep).with(2.0).when(time_state.is('initial')).then(time_state.is('slept_once'))
    self.expects(:do_some_work).when(time_state.is('slept_once'))

    Whitehall::Wait.until(2.seconds.from_now) do
      do_some_work
    end
  end

  test "re-sleeps if the actual time slept is less than that asked for" do
    time_state = states('time_state').starts_as('initial')
    Time.zone.stubs(:now).when(time_state.is('initial')).returns(@base_time)
    Time.zone.stubs(:now).when(time_state.is('slept_once')).returns(@base_time + 45.seconds)
    Time.zone.stubs(:now).when(time_state.is('slept_twice')).returns(@base_time + 48.seconds)
    Time.zone.stubs(:now).when(time_state.is('slept_thrice')).returns(@base_time + 50.seconds)

    Whitehall::Wait.expects(:sleep).with(50.0).when(time_state.is('initial')).then(time_state.is('slept_once'))
    Whitehall::Wait.expects(:sleep).with(5.0).when(time_state.is('slept_once')).then(time_state.is('slept_twice'))
    Whitehall::Wait.expects(:sleep).with(2.0).when(time_state.is('slept_twice')).then(time_state.is('slept_thrice'))
    self.expects(:do_some_work).when(time_state.is('slept_thrice'))

    Whitehall::Wait.until(50.seconds.from_now) do
      do_some_work
    end
  end

private

  def do_some_work
    Whitehall::Random.base32
  end
end
