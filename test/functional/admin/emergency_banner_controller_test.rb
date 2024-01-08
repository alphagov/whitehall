require "fakeredis/minitest"
require "test_helper"

class Admin::EmergencyBannerControllerTest < ActionController::TestCase
  extend Minitest::Spec::DSL

  setup do
    login_as :gds_admin
    @controller = Admin::EmergencyBannerController.new
  end

  should_be_an_admin_controller

  %i[show].each do |action_method|
    test "#{action_method} action is not permitted to non-GDS admins" do
      login_as :departmental_editor
      get action_method
      assert_response :forbidden
    end
  end

  context "when the banner is disabled" do
    view_test "GET :show does not list the current banner" do
      get :show

      assert_response :success
      assert_select "p.govuk-body", text: "The emergency banner is not currently deployed."
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
  end
end
