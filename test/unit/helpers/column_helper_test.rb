# encoding: UTF-8
# *NOTE* this file deliberately does not include test_helper
# in order to attempt to speed up the tests
#
require File.expand_path("../../../fast_test_helper", __FILE__)
require 'app/helpers/column_helper'

class ColumnHelperTest < ActiveSupport::TestCase
  setup do
    @subject = stub.extend(ColumnHelper)
  end

  def columnize(target)
    @yielded = []
    @subject.columnize(target) do |value|
      @yielded << value
    end
    @yielded
  end

  test "columnize does nothing with an empty array" do
    assert_equal [[], []], columnize([])
  end

  test "columnize yields its value when there is just one element in the array" do
    assert_equal [[1], []], columnize([1])
  end

  test "columnize yields first half then second half if more than one given element" do
    assert_equal [[1, 3, 5], [2, 4, 6]], columnize((1..6).to_a)
    assert_equal [[1, 3, 5], [2, 4]], columnize((1..5).to_a)
  end
end
