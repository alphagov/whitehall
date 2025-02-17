require "test_helper"

class ComponentGuideHelperTest < ActionView::TestCase
  include ComponentGuideHelper

  test "overrides the `component_doc_path` method" do
    assert_equal("/component-guide/foo", component_doc_path("foo"))
  end
end
