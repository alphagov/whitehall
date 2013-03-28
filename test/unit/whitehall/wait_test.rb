require 'test_helper'

class WaitTest < ActiveSupport::TestCase

  test "sleeps for the number of seconds until the timestamp before executing the block" do
    order_of_work = sequence('order of work')
    Whitehall::Wait.expects(:sleep).returns(2).in_sequence(order_of_work)
    self.expects(:do_some_work).in_sequence(order_of_work)

    Timecop.freeze(Time.zone.now) do
      Whitehall::Wait.until(2.seconds.from_now) do
        do_some_work
      end
    end

  end

  test "re-sleeps if the actual time slept is less than that asked for" do
    order_of_work = sequence('order of work')
    Whitehall::Wait.expects(:sleep).returns(45).in_sequence(order_of_work)
    Whitehall::Wait.expects(:sleep).returns(3).in_sequence(order_of_work)
    Whitehall::Wait.expects(:sleep).returns(2).in_sequence(order_of_work)
    self.expects(:do_some_work).in_sequence(order_of_work)

    Timecop.freeze(Time.zone.now) do
      Whitehall::Wait.until(50.seconds.from_now) do
        do_some_work
      end
    end
  end

  private

  def do_some_work
    Whitehall::Random.base32
  end
end
