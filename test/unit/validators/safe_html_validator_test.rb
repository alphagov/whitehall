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
end
