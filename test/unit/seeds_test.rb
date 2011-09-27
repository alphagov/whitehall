require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  test "loading seeds.rb doesn't cause errors" do
    assert_nothing_raised do
      load Rails.root + "db" + "seeds.rb"
    end
  end
end