require 'test_helper'

class PluralizeHelperTest < ActionView::TestCase
  include PluralizeHelper

  class OriginalHelper
    include ActionView::Helpers::TextHelper
  end

  test "behaves like regular Rails test helper" do
    examples = [
                [1, 'policy'],
                [2, 'policy'],
                [3, 'sheep']
               ]
    original = OriginalHelper.new
    examples.each do |args|
      assert_equal pluralize(*args), original.pluralize(*args)
    end
  end

  test "can be passed a block for formatting" do
    expected = '2 - policies'
    actual = pluralize(2, 'policy') do |count_str, suffix|
      "#{count_str} - #{suffix}"
    end
    assert_equal expected, actual
  end
end
