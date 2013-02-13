require 'test_helper'

class TranslationHelperTest < ActionView::TestCase
  setup do
    @document = stub('document', display_type_key: 'stub')
  end

  test "#t_display_type capitalizes translated document display type" do
    stubs(:t).with('document.type.stub').returns('stub')
    assert_equal "Stub", t_display_type(@document)
  end

  test "#t_display_type does not break existing capitalization" do
    stubs(:t).with('document.type.stub').returns('ACRONYM stub')
    assert_equal "ACRONYM stub", t_display_type(@document)
  end
end
