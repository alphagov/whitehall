require "test_helper"

class ContentObjectStore::ChangeDispatcherTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  test "returns a human readable verb for each type of dispatcher" do
    assert_equal "changed and published", ContentObjectStore::ChangeDispatcher::Now.new.verb
    assert_equal "scheduled", ContentObjectStore::ChangeDispatcher::Schedule.new.verb
  end
end
