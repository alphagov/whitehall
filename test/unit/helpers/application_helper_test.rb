require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "should mark the govspeak output as html safe" do
    html = govspeak_to_html("govspeak-text")
    assert html.html_safe?
  end
end
