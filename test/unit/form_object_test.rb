require "test_helper"

class FormObjectTest < ActiveSupport::TestCase
  test "#initialize should set attributes from the given hash" do
    test_form_object = Class.new(FormObject) do
      attr_accessor :foo
    end
    assert_equal "bar", test_form_object.new(foo: "bar").foo
  end

  test ".named should set the model name to the given name as far as rails in concerned" do
    test_form_object = Class.new(FormObject) do
      named "FooBar"
    end
    assert_equal "FooBar", test_form_object.model_name.to_s
    assert test_form_object.model_name.is_a? ActiveModel::Name
  end
end
