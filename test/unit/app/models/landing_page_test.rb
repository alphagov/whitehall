require "test_helper"

class LandingPageTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_protect_against_xss_and_content_attacks_on :landing_page, :body

  test "landing-page base_path is not overwritten from title" do
    landing_page = build(:landing_page, slug_override: "/landing-page/test")
    assert_equal landing_page.base_path, "/landing-page/test"
  end

  test "landing-page is not valid if base_path is already in use" do
    create(:landing_page, slug_override: "/landing-page/test")

    landing_page = build(:landing_page, slug_override: "/landing-page/test")
    assert_not landing_page.valid?
    assert_equal :base_path, landing_page.errors.first.attribute
  end

  test "landing-page is not valid if base_path does not start with a slash" do
    landing_page = build(:landing_page, body: "blocks: []", slug_override: "/landing-page/test")
    assert_not landing_page.valid?
  end

  test "landing-page is valid if body is YAML with at least one block" do
    landing_page = build(:landing_page, slug_override: "/landing-page/test", body: "blocks: [{ type: some-type }]\nother:\n")
    assert landing_page.valid?
  end

  test "landing-page is not valid if body is not YAML with at least the blocks: element" do
    landing_page = build(:landing_page, slug_override: "/landing-page/test", body: "blinks:")
    assert_not landing_page.valid?
    assert_equal :body, landing_page.errors.first.attribute
  end

  test "landing-page is valid if includes the extends: and the extends element is valid" do
    create(:landing_page, slug_override: "/homepage", body: "blocks: [{ type: some-type }]")
    landing_page = build(:landing_page, slug_override: "/other-page", body: "extends: /homepage\nblocks: [{ type: some-type }]")
    assert landing_page.valid?
  end

  test "landing-page is not valid if includes the extends: element but the page to extend does not exist" do
    landing_page = build(:landing_page, slug_override: "/landing-page/test", body: "extends: /homepage\nblocks:")
    assert_not landing_page.valid?
    assert_equal :body, landing_page.errors.first.attribute
  end
end
