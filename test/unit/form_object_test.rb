require 'test_helper'

class FormObjectTest < ActiveSupport::TestCase
  test "#initialize should set attributes from the given hash" do
    class TestFormObject < FormObject
      attr_accessor :foo
    end
    assert_equal "bar", TestFormObject.new(foo: "bar").foo
  end

  test ".named should set the model name to the given name as far as rails in concerned" do
    class TestFormObject < FormObject
      named "FooBar"
    end
    assert_equal "FooBar", TestFormObject.model_name.to_s
    assert TestFormObject.model_name.is_a? ActiveModel::Name
  end
end
