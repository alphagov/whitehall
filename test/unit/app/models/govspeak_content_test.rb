require "test_helper"

class GovspeakContentTest < ActiveSupport::TestCase
  def setup
    Whitehall.stubs(:skip_safe_html_validation).returns(false)
  end

  test "body cannot be blank" do
    govspeak_content = create(:html_attachment).govspeak_content

    govspeak_content.body = nil
    assert_not govspeak_content.valid?

    govspeak_content.body = ""
    assert_not govspeak_content.valid?

    govspeak_content.body = "Something"
    assert govspeak_content.valid?
  end

  test "it must belong to a HTML attachment" do
    govspeak_content = create(:html_attachment).govspeak_content

    assert govspeak_content.valid?

    govspeak_content.html_attachment = nil
    assert_not govspeak_content.valid?
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
