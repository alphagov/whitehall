require 'test_helper'

class RankTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    rank = build(:rank)
    assert rank.valid?
  end

  test "should be invalid without a name" do
    rank = build(:rank, name: nil)
    refute rank.valid?
  end
end