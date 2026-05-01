require "test_helper"

class PlanForChangeLandingPageTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  should_protect_against_xss_and_content_attacks_on :plan_for_change_landing_page, :body

  test "landing-page base_path is not overwritten from title" do
    plan_for_change_landing_page = create(:plan_for_change_landing_page, title: "New title", slug_override: "/landing-page/test")

    assert_equal plan_for_change_landing_page.slug, "/landing-page/test"
    assert_equal plan_for_change_landing_page.base_path, "/landing-page/test"
  end

  test "landing-page slug gets set to the value of the slug_override" do
    plan_for_change_landing_page = create(:plan_for_change_landing_page, slug_override: "/landing-page/test")

    assert_equal plan_for_change_landing_page.slug, "/landing-page/test"
  end

  test "landing-page is not valid if slug_override is nil" do
    plan_for_change_landing_page = build(:plan_for_change_landing_page, slug_override: nil)
    assert_not plan_for_change_landing_page.valid?
    assert_equal "cannot be blank", plan_for_change_landing_page.errors[:slug_override].first
  end

  test "landing-page is not valid if slug_override is already in use" do
    create(:plan_for_change_landing_page, slug_override: "/landing-page/test")
    plan_for_change_landing_page = build(:plan_for_change_landing_page, slug_override: "/landing-page/test")
    assert_not plan_for_change_landing_page.valid?
    assert_equal "is already taken", plan_for_change_landing_page.errors[:slug_override].first
  end

  test "landing-page is not valid if slug_override does not start with a slash" do
    plan_for_change_landing_page = build(:plan_for_change_landing_page, slug_override: "landing-page/test")
    assert_not plan_for_change_landing_page.valid?
    assert_equal "must start with a slash (/)", plan_for_change_landing_page.errors[:slug_override].first
  end

  test "landing-page is valid if body is YAML with at least one block" do
    plan_for_change_landing_page = build(:plan_for_change_landing_page, slug_override: "/landing-page/test", body: "blocks: [{ type: some-type }]\nother:\n")
    assert plan_for_change_landing_page.valid?
  end

  test "landing-page is not valid if body is not YAML with at least the blocks: element" do
    plan_for_change_landing_page = build(:plan_for_change_landing_page, slug_override: "/landing-page/test", body: "blinks:")
    assert_not plan_for_change_landing_page.valid?
    assert_equal :body, plan_for_change_landing_page.errors.first.attribute
  end

  test "landing-page is valid if includes the extends: and the extends element is valid" do
    create(:plan_for_change_landing_page, slug_override: "/homepage", body: "blocks: [{ type: some-type }]")
    plan_for_change_landing_page = build(:plan_for_change_landing_page, slug_override: "/other-page", body: "extends: /homepage\nblocks: [{ type: some-type }]")
    assert plan_for_change_landing_page.valid?
  end

  test "landing-page is not valid if includes the extends: element but the page to extend does not exist" do
    plan_for_change_landing_page = build(:plan_for_change_landing_page, slug_override: "/landing-page/test", body: "extends: /homepage\nblocks:")
    assert_not plan_for_change_landing_page.valid?
    assert_equal :body, plan_for_change_landing_page.errors.first.attribute
  end
end
