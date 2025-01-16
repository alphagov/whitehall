require "test_helper"

class PhaseBannerTest < ActionDispatch::IntegrationTest
  test "uses the show_banner value in the whats_new.yml file to determine whether to render the whats new banner" do
    login_as create(:gds_editor)
    get admin_root_path

    if I18n.t("admin.whats_new.show_banner")
      assert_select "#whats_new_banner .govuk-phase-banner__content__tag", text: "What's new"
    else
      assert_select "#whats_new_banner.gem-c-phase-banner", count: 0
    end
  end

  test "uses the show_banner value in the whats_new.yml file to determine whether to render the feedback banner" do
    login_as create(:gds_editor)
    get admin_root_path

    if I18n.t("admin.feedback.show_banner")
      assert_select "#feedback_banner .govuk-phase-banner__content__tag", text: "Feedback"
    else
      assert_select "#feedback_banner", count: 0
    end
  end

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
