require "test_helper"
require "capybara/rails"

class Admin::ErrorsControllerTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  extend Minitest::Spec::DSL

  setup do
    login_as_admin
  end

  ERROR_LOOKUPS = {
    "400": :bad_request,
    "403": :forbidden,
    "404": :not_found,
    "422": :unprocessable_entity,
    "500": :internal_server_error,
  }.freeze

  ERROR_LOOKUPS.each do |error_code, error|
    it "should show the #{error} page" do
      get "/#{error_code}"

      assert_template error
    end

    it "should render the correct headers" do
      get "/#{error_code}"

      assert_select ".govuk-header__product-name", text: Whitehall.product_name
      refute_select ".govuk-phase-banner__content__tag"
    end

    it "should render the product name in the title" do
      get "/#{error_code}"

      assert_select "title", text: /#{Whitehall.product_name}/
    end
  end

  describe "when request comes from ContentBlockManager" do
    before do
      path = "some-path"
      ActionDispatch::Request.any_instance.stubs(:path).returns(path)
      path.stubs(:start_with?).with(ContentBlockManager.router_prefix).returns(true)
    end

    ERROR_LOOKUPS.each do |error_code, error|
      it "should show the #{error} page" do
        get "/#{error_code}"

        assert_template error
      end

      it "should render the correct headers" do
        get "/#{error_code}"

        assert_select ".govuk-header__product-name", text: ContentBlockManager.product_name
        assert_select ".govuk-phase-banner__content__tag", text: "Beta"
      end

      it "should render the product name in the title" do
        get "/#{error_code}"

        assert_select "title", text: /#{ContentBlockManager.product_name}/
      end
    end
  end
end
