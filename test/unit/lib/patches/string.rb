require "test_helper"

class StringTest < ActiveSupport::TestCase
  test "`articleize` uses correct `article` for a given word" do
    assert_equal "an apple", "apple".articleize
    assert_equal "a banana", "banana".articleize
  end
end
