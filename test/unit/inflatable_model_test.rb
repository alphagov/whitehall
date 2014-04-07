require 'test_helper'

class InflatableModelTest < ActiveSupport::TestCase
  test "#initialize should assign to declared attributes from passed in hash" do
    class InflatableModelTestClass < InflatableModel
      attr_accessor :foo
    end

    assert_equal 'bar', InflatableModelTestClass.new(foo: 'bar').foo
  end
end
