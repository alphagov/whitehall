require "test_helper"

class LandingPageTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_protect_against_xss_and_content_attacks_on :landing_page, :body

  test "landing-page is not valid if base_path is already in use" do
    create(:document, slug: "/landing-page/test")

    document = build(:document, slug: "/landing-page/test")
    landing_page = build(:landing_page, document:)
    assert_not landing_page.valid?
    assert_equal :base_path, landing_page.errors.first.attribute
  end

  test "landing-page is not valid if body is not YAML with a root of blocks: " do
    document = build(:document, slug: "/landing-page/test")
    landing_page = build(:landing_page, document:, body: "blinks:")
    assert_not landing_page.valid?
    assert_equal :body, landing_page.errors.first.attribute
  end
end
