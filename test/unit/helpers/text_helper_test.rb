require "test_helper"

class TextHelperTest < ActionView::TestCase
  test "#with_this_determiner prefixes singular strings with 'this'" do
    assert_equal with_this_determiner("dog"), "this dog"
  end

  test "#with_this_determiner prefixes plural strings with 'these'" do
    assert_equal with_this_determiner("statistics"), "these statistics"
  end
end
