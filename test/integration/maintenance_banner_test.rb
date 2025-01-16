require "test_helper"

class MaintenanceBannerTest < ActionDispatch::IntegrationTest
  test "uses the configuration value in the maintenance_banner.yml locale file to determine whether to render the banner" do
    login_as create(:gds_editor)
    get admin_root_path

    if I18n.t("admin.maintenance_banner.show_banner")
      assert_select "#maintenance_banner .govuk-phase-banner__content__tag", text: "Maintenance"
      assert_select "#maintenance_banner .govuk-phase-banner__text", text: I18n.t("admin.maintenance_banner.message")
    else
      assert_select "#maintenance_banner", count: 0
    end
  end
end
