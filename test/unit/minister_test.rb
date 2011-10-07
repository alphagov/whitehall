require 'test_helper'

class MinisterTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    minister = build(:minister)
    assert minister.valid?
  end
  
  test "should be invalid without a name" do
    minister = build(:minister, name: nil)
    refute minister.valid?
  end
end