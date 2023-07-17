require "test_helper"
require "capybara/rails"

class AdminAnalyticsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def log_out
    GDS::SSO.test_user = nil
  end

  setup do
    ENV["GDS_SSO_MOCK_INVALID"] = "1"
  end

  teardown do
    ENV.delete("GDS_SSO_MOCK_INVALID")
  end

  def refute_dimension_is_set(dimension)
    assert_equal page.all("meta[name='custom-dimension:#{dimension}']", visible: false).count, 0
  end

  def assert_dimension_is_set(dimension, with_value: "not set")
    assert page.find("meta[name='custom-dimension:#{dimension}'][content='#{with_value}']", visible: false)
  end

  test "send a GA event including the users org slug when successfully signed-in with the preview design system permission" do
    login_as(create(:user, :with_preview_design_system, name: "user-name", email: "user@example.com", organisation_slug: "ministry-of-lindy-hop"))
    visit admin_root_path
    assert_dimension_is_set(8, with_value: "ministry-of-lindy-hop")
  end

  test "send a GA event including '(not set)' for the org slug when the user has no org abd the preview design system permission" do
    login_as(create(:user, :with_preview_design_system, name: "user-name", email: "user@example.com", organisation_slug: nil))
    visit admin_root_path
    assert_dimension_is_set(8, with_value: "(not set)")
  end
end
