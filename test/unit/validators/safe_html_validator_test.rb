require 'test_helper'

class SafeHtmlValidatorTest < ActiveSupport::TestCase
  def setup
    Whitehall.stubs(:skip_safe_html_validation).returns(false)
  end

  test "it marks HTML-unsafe attributes as such" do
    test_model = build(:publication, body: '<script>alert("hax!")</script>', title: 'Safe title')

    SafeHtmlValidator.new({}).validate(test_model)

    assert_equal 1, test_model.errors.size
    assert_equal ["cannot include invalid formatting or JavaScript"], test_model.errors[:body]
  end

  test "span and div elements are considered safe" do
    test_model = GovspeakContent.new(computed_body_html: '<div class="govspeak"><span class="number">1</span></div>')

    SafeHtmlValidator.new({}).validate(test_model)
    assert test_model.errors.empty?, test_model.errors.full_messages.inspect
  end
end
