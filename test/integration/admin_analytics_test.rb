require 'test_helper'
require 'capybara/rails'

class AdminAnalyticsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  def log_out
    GDS::SSO.test_user = nil
  end

  setup do
    ENV['GDS_SSO_MOCK_INVALID'] = '1'
  end

  teardown do
    ENV.delete('GDS_SSO_MOCK_INVALID')
  end

  # GA is noisy in tests because all GA calls become console.log so we
  # don't want it enabled for all tests, use this to selectively turn it on
  def with_ga_enabled
    begin
      GovukAdminTemplate.configure { |c| c.enable_google_analytics_in_tests = true }
      yield
    ensure
      GovukAdminTemplate.configure { |c| c.enable_google_analytics_in_tests = false }
    end
  end

  def refute_dimension_is_set(dimension)
    refute_match(/#{Regexp.escape("GOVUKAdmin.setDimension(#{dimension}")}/, page.body)
  end

  def assert_dimension_is_set(dimension, with_value: nil)
    dimension_set_js_code = "GOVUKAdmin.setDimension(#{dimension}"
    dimension_set_js_code += ", \"#{with_value}\")" if with_value.present?
    assert_match(/#{Regexp.escape(dimension_set_js_code)}/, page.body)
  end

  test "send a GA event including the users org slug when successfully signed-in" do
    with_ga_enabled do
      login_as(create(:user, name: "user-name", email: "user@example.com", organisation_slug: "ministry-of-lindy-hop"))
      visit admin_root_path
      assert_dimension_is_set(8, with_value: "ministry-of-lindy-hop")
    end
  end

  test "send a GA event including '(not set)' for the org slug when the user has no org" do
    with_ga_enabled do
      login_as(create(:user, name: "user-name", email: "user@example.com", organisation_slug: nil))
      visit admin_root_path
      assert_dimension_is_set(8, with_value: "(not set)")
    end
  end

  test "does not send GA event for logged in users on non admin pages" do
    with_ga_enabled do
      login_as(create(:user, name: "user-name", email: "user@example.com", organisation_slug: "ministry-of-lindy-hop"))
      visit admin_root_path
      assert_dimension_is_set(8)

      # this is a public page that requires no db setup
      visit get_involved_path
      refute_dimension_is_set(8)
    end
  end
end
