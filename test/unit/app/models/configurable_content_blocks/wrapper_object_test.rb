require "test_helper"

class ConfigurableContentBlocks::WrapperObjectTest < ActiveSupport::TestCase
  test "it uses the same form view partial as the default object" do
    wrapper_object = ConfigurableContentBlocks::WrapperObject.new(nil)
    assert_equal "admin/configurable_content_blocks/default_object", wrapper_object.to_partial_path
  end
end
