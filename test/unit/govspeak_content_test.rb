require "test_helper"

class GovspeakContentTest < ActiveSupport::TestCase
  def setup
    Whitehall.stubs(:skip_safe_html_validation).returns(false)
  end

  test "validates user input for HTML safety" do
    govspeak_content = create(:html_attachment).govspeak_content

    govspeak_content.body = "# Hello world"
    assert_equal true, govspeak_content.valid?

    govspeak_content.body = '<script>alert("hax!")</script>'
    assert_equal false, govspeak_content.valid?
    assert_equal %i[body], govspeak_content.errors.group_by_attribute.keys
  end
end
