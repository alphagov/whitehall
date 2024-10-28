require "test_helper"

class LandingPageTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_protect_against_xss_and_content_attacks_on :landing_page, :body

  test "landing-page base_path is not overwritten from title" do
    document = build(:document, slug: "/landing-page/test")
    landing_page = build(:landing_page, document:)
    assert_equal landing_page.base_path, "/landing-page/test"
  end

  test "landing-page is not valid if base_path is already in use" do
    create(:document, slug: "/landing-page/test")

    document = build(:document, slug: "/landing-page/test")
    landing_page = build(:landing_page, document:)
    assert_not landing_page.valid?
    assert_equal :base_path, landing_page.errors.first.attribute
  end

  test "landing-page is valid if body is YAML with at least the blocks: element" do
    document = build(:document, slug: "/landing-page/test")
    landing_page = build(:landing_page, document:, body: "blocks:\nother:\n")
    assert landing_page.valid?
  end

  test "landing-page is not valid if body is not YAML with at least the blocks: element" do
    document = build(:document, slug: "/landing-page/test")
    landing_page = build(:landing_page, document:, body: "blinks:")
    assert_not landing_page.valid?
    assert_equal :body, landing_page.errors.first.attribute
  end

  test "landing-page is valid if includes the extends: and the extends element is valud" do
    create(:document, slug: "/homepage")

    document = build(:document, slug: "/landing-page/test")
    landing_page = build(:landing_page, document:, body: "extends: /homepage\nblocks:")
    assert landing_page.valid?
  end

  test "landing-page is not valid if includes the extends: element but the page to extend does not exist" do
    document = build(:document, slug: "/landing-page/test")
    landing_page = build(:landing_page, document:, body: "extends: /homepage\nblocks:")
    assert_not landing_page.valid?
    assert_equal :body, landing_page.errors.first.attribute
  end
end
