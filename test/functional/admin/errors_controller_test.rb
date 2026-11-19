require "test_helper"
require "capybara/rails"

class Admin::ErrorsControllerTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL

  ERRORS = {
    "400": { template: :bad_request, exception: ActionController::BadRequest },
    "404": { template: :not_found, exception: ActiveRecord::RecordNotFound },
    "422": { template: :unprocessable_content, exception: ActionController::InvalidAuthenticityToken },
    "500": { template: :internal_server_error, exception: StandardError },
  }.freeze

  setup do
    @env_config = Rails.application.env_config.slice(
      "action_dispatch.show_exceptions",
      "action_dispatch.show_detailed_exceptions",
    )
    Rails.application.env_config["action_dispatch.show_exceptions"] = :all
    Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false

    login_as_admin
  end

  teardown do
    Rails.application.env_config.merge!(@env_config)
  end

  ERRORS.each do |error_code, error|
    it "should show the #{error[:template]} page when a #{error[:exception]} is raised" do
      Admin::DashboardController.any_instance.stubs(:index).raises(error[:exception])

      get admin_root_path

      assert_response error_code.to_s.to_i
      assert_template error[:template]
      assert_select ".govuk-header__product-name", text: Whitehall.product_name
      assert_select "title", text: /#{Whitehall.product_name}/
    end
  end

  it "should show the forbidden page when a route constraint denies permission" do
    login_as(create(:user, permissions: []))

    get "/component-guide"

    assert_response :forbidden
    assert_template :forbidden
    assert_select ".govuk-header__product-name", text: Whitehall.product_name
    assert_select "title", text: /#{Whitehall.product_name}/
  end

  %w[400 403 404 422 500].each do |error_code|
    it "should return a 404 when /#{error_code} is requested directly" do
      get "/#{error_code}"

      assert_response :not_found
      assert_template :not_found
    end
  end

  it "should render the not_found page when not authenticated" do
    logout
    ENV["GDS_SSO_MOCK_INVALID"] = "true"

    get "/a-page-that-does-not-exist"

    assert_response :not_found
    assert_template :not_found
  ensure
    ENV.delete("GDS_SSO_MOCK_INVALID")
  end
end
