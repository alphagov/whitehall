require "test_helper"

class WhatsNewTest < ActionDispatch::IntegrationTest
  test "it shows whats new page" do
    login_as create(:gds_editor)
    get admin_whats_new_path

    assert_select "h1", text: "What’s new in Whitehall Publisher"
  end

  test "it shows the date of the most recent change as the last updated date" do
    login_as create(:gds_editor)
    get admin_whats_new_path

    latest = I18n.t("admin.whats_new.recent_changes.updates").map { |update| Date.parse(update[:date]) }.max
    assert_select ".app-view-whats-new__last-updated", text: "Last updated #{latest.strftime('%-d %B %Y')}"
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
end
