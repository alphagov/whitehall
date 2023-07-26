require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "Current.user" do
    it "is nil by default" do
      assert_nil Current.user
    end

    it "can be set to the currently logged in user" do
      current_user = build(:user)
      Current.user = current_user
      assert_equal current_user, Current.user
    end

    it "is thread safe" do
      user_one = build(:user, name: "Thread 1 user")
      user_two = build(:user, name: "Thread 2 user")

      # emulate a race condition between two threads
      [
        Thread.new do
          Current.user = user_one
          sleep(0.2) # wait 200ms so the other thread can mutate state
          assert_equal user_one.name, Current.user.name
        end,
        Thread.new do
          Current.user = user_two
          assert_equal user_two.name, Current.user.name
        end,
      ].each(&:join)
    end
  end
end
