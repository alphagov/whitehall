require 'test_helper'

class TranslationHelperTest < ActionView::TestCase
  setup do
    @document = stub('document', display_type_key: 'stub')
  end

  test "#t_display_type translates document display type" do
    I18n.backend.store_translations :en, {document: {type: {stub: {one: 'Stub'}}}}
    assert_equal "Stub", t_display_type(@document)
  end
end
