require "test_helper"

class WhatsNewTest < ActionDispatch::IntegrationTest
  test "it shows whats new page" do
    @user = create(:gds_editor)
    login_as @user

    get admin_whats_new_path
    assert_select "h1", text: "What’s new in Whitehall Publisher"
  end

  test "each section has h2 and a back to top link" do
    @user = create(:gds_editor)
    login_as @user

    get admin_whats_new_path
    assert_select ".app-view-whats-new__section" do |sections|
      sections.each do |section|
        assert_select section, "h2", count: 1
        assert_select section, ".app-view-whats-new__back-to-top-link", count: 1
      end
    end
  end
end
