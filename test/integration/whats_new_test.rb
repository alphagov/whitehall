require "test_helper"

class WhatsNewTest < ActionDispatch::IntegrationTest
  test "it shows whats new page" do
    login_as create(:gds_editor)
    get admin_whats_new_path

    assert_select "h1", text: "What’s new in Whitehall Publisher"
  end

  test "each section has h2 and a back to top link" do
    login_as create(:gds_editor)
    get admin_whats_new_path

    assert_select ".app-view-whats-new__section" do |sections|
      sections.each do |section|
        assert_select section, "h2", count: 1
        assert_select section, ".app-view-whats-new__back-to-top-link", count: 1
      end
    end
  end

  test "uses the show_banner value in the whats_new.yml file to determine whether to render the banner" do
    login_as create(:gds_editor)
    get admin_whats_new_path

    if I18n.t("admin.whats_new.show_banner") || I18n.t("admin.feedback.show_banner")
      assert_select ".gem-c-phase-banner", count: 1
    else
      assert_select ".gem-c-phase-banner", count: 0
    end
  end
end
