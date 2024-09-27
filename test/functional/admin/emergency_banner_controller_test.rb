require "fakeredis/minitest"
require "test_helper"

class Admin::EmergencyBannerControllerTest < ActionController::TestCase
  extend Minitest::Spec::DSL

  setup do
    login_as :gds_admin
    @controller = Admin::EmergencyBannerController.new
  end

  should_be_an_admin_controller

  %i[confirm_destroy edit show].each do |action_method|
    test "#{action_method} action is not permitted to non-GDS admins" do
      login_as :departmental_editor
      get action_method
      assert_response :forbidden
    end
  end

  test "destroy action is not permitted to non-GDS admins" do
    login_as :departmental_editor
    delete :destroy
    assert_response :forbidden
  end

  test "update action is not permitted to non-GDS admins" do
    login_as :departmental_editor
    patch :update
    assert_response :forbidden
  end

  context "when the banner is disabled" do
    view_test "GET :show does not list the current banner" do
      get :show

      assert_response :success
      assert_select "p.govuk-body", text: "The emergency banner is not currently deployed."
    end

    view_test "GET :edit shows a blank form" do
      get :edit

      assert_response :success
      assert_select "#emergency_banner_campaign_class", value: nil
      assert_select "#emergency_banner_heading", value: nil
      assert_select "#emergency_banner_short_description", value: nil
      assert_select "#emergency_banner_link", value: nil
      assert_select "#emergency_banner_link_text", value: nil
    end

    view_test "PATCH :update saves the values" do
      patch :update, params: {
        emergency_banner: {
          campaign_class: "national-emergency",
          heading: "Some information",
          short_description: "Something has happened",
          link: "https://www.emergency.gov.uk",
          link_text: "A link",
        },
      }

      expected_response = {
        campaign_class: "national-emergency",
        heading: "Some information",
        short_description: "Something has happened",
        link: "https://www.emergency.gov.uk",
        link_text: "A link",
      }

      assert_response :redirect
      assert_equal expected_response, Redis.new.hgetall("emergency_banner").symbolize_keys
    end
  end

  context "when the banner is enabled" do
    before do
      Redis.new.hmset(
        :emergency_banner,
        :campaign_class,
        "national-emergency",
        :heading,
        "Some important information",
        :short_description,
        "Something important has happened",
        :link,
        "https://www.emergency.gov.uk",
        :link_text,
        "See more",
      )
    end

    view_test "GET :show lists the current banner" do
      get :show

      assert_response :success
      assert_select "p.govuk-body", text: "The emergency banner is currently deployed with the following content."

      assert_select "tr.govuk-table__row:nth-of-type(1) td", text: "Campaign class"
      assert_select "tr.govuk-table__row:nth-of-type(1) td", text: "National emergency"

      assert_select "tr.govuk-table__row:nth-of-type(2) td", text: "Heading"
      assert_select "tr.govuk-table__row:nth-of-type(2) td", text: "Some important information"

      assert_select "tr.govuk-table__row:nth-of-type(3) td", text: "Short description (optional)"
      assert_select "tr.govuk-table__row:nth-of-type(3) td", text: "Something important has happened"

      assert_select "tr.govuk-table__row:nth-of-type(4) td", text: "Link URL (optional)"
      assert_select "tr.govuk-table__row:nth-of-type(4) td", text: "https://www.emergency.gov.uk"

      assert_select "tr.govuk-table__row:nth-of-type(5) td", text: "Link text (optional)"
      assert_select "tr.govuk-table__row:nth-of-type(5) td", text: "See more"
    end

    view_test "GET :edit shows a populated form" do
      get :edit

      assert_response :success
      assert_select "#emergency_banner_campaign_class", value: "National emergency"
      assert_select "#emergency_banner_heading", value: "Some important information"
      assert_select "#emergency_banner_short_description", value: "Something important has happened"
      assert_select "#emergency_banner_link", value: "https://www.emergency.gov.uk"
      assert_select "#emergency_banner_link_text", value: "See more"
    end

    view_test "PATCH :update saves the values" do
      patch :update, params: {
        emergency_banner: {
          campaign_class: "local-emergency",
          heading: "Some updated information",
          short_description: "An update has been made",
          link: "https://www.updated-emergency.gov.uk",
          link_text: "An updated link",
        },
      }

      expected_response = {
        campaign_class: "local-emergency",
        heading: "Some updated information",
        short_description: "An update has been made",
        link: "https://www.updated-emergency.gov.uk",
        link_text: "An updated link",
      }

      assert_response :redirect
      assert_equal expected_response, Redis.new.hgetall("emergency_banner").symbolize_keys
    end

    view_test "GET :confirm_destroy requests confirmation" do
      get :confirm_destroy

      assert_response :success
      assert_select "p.govuk-body", text: "Are you sure you want to remove the emergency banner?"
    end

    view_test "DELETE :destroy removes the values" do
      delete :destroy

      expected_response = {}

      assert_response :redirect
      assert_equal expected_response, Redis.new.hgetall("emergency_banner").symbolize_keys
    end
  end

  context "instantiating Redis" do
    setup do
      @mock_redis = Minitest::Mock.new
      def @mock_redis.hgetall(*args); end
      def @mock_redis.del(*args); end
    end
    context "when the EMERGENCY_BANNER_REDIS_URL environment variable has been set" do
      view_test "uses that value as the URL for the Redis client" do
        mock_env("EMERGENCY_BANNER_REDIS_URL" => "redis://emergency-banner") do
          Redis.expects(:new).with(
            url: "redis://emergency-banner",
            reconnect_attempts: 4,
            reconnect_delay: 15,
            reconnect_delay_max: 60,
          ).twice.returns(@mock_redis)

          delete :destroy
        end
      end
    end

    context "when the EMERGENCY_BANNER_REDIS_URL environment variable has not been set" do
      view_test "uses the default REDIS_URL as the URL for the Redis client" do
        mock_env({
          "EMERGENCY_BANNER_REDIS_URL" => nil,
          "REDIS_URL" => "redis://my-redis-url",
        }) do
          Redis.expects(:new).with(
            url: "redis://my-redis-url",
            reconnect_attempts: 4,
            reconnect_delay: 15,
            reconnect_delay_max: 60,
          ).twice.returns(@mock_redis)

          delete :destroy
        end
      end
    end
  end

  def mock_env(partial_env_hash)
    old_env = ENV.to_hash
    ENV.update partial_env_hash
    begin
      yield
    ensure
      ENV.replace old_env
    end
  end
end
