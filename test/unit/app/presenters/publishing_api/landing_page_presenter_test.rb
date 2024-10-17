require "test_helper"

class PublishingApi::LandingPagePresenterTest < ActiveSupport::TestCase
  setup do
    @landing_page = create(
      :landing_page,
      document: create(:document, id: 12_345, slug: "/landing-page/test"),
      title: "Landing Page title",
      summary: "Landing Page summary",
      first_published_at: @first_published_at = Time.zone.now,
      updated_at: 1.year.ago,
    )

    @presented_landing_page = PublishingApi::LandingPagePresenter.new(@landing_page)
    @presented_content = I18n.with_locale("en") { @presented_landing_page.content }
    @presented_links = I18n.with_locale("en") { @presented_landing_page.links }
  end

  test "it presents a valid landing_page content item" do
    assert_valid_against_publisher_schema @presented_content, "landing_page"
    assert_valid_against_links_schema({ links: @presented_links }, "landing_page")
  end

  test "it delegates the content id" do
    assert_equal @landing_page.content_id, @presented_landing_page.content_id
  end

  test "it presents the title" do
    assert_equal "Landing Page title", @presented_content[:title]
  end

  test "it presents the summary as the description" do
    assert_equal "Landing Page summary", @presented_content[:description]
  end

  test "it presents the base_path" do
    assert_equal "/landing-page/test", @presented_content[:base_path]
  end

  test "it presents updated_at if public_timestamp is nil" do
    @landing_page.update_columns(public_timestamp: nil)
    @presented_content = I18n.with_locale("de") { @presented_landing_page.content }
    assert_equal @landing_page.updated_at, @presented_content[:public_updated_at]
  end

  test "it presents the publishing_app as whitehall" do
    assert_equal Whitehall::PublishingApp::WHITEHALL, @presented_content[:publishing_app]
  end

  test "it presents the rendering_app as frontend" do
    assert_equal "frontend", @presented_content[:rendering_app]
  end

  test "it presents the schema_name as landing_page" do
    assert_equal "landing_page", @presented_content[:schema_name]
  end

  test "it presents the document type as landing_page" do
    assert_equal "landing_page", @presented_content[:document_type]
  end

  test "it presents the global process wide locale as the locale of the landing_page" do
    assert_equal "en", @presented_content[:locale]
  end

  test "it presents the first_published_at in UTC" do
    assert_equal @first_published_at.utc, @presented_content[:first_published_at]
  end

  test "it presents the auth bypass id" do
    assert_equal [@landing_page.auth_bypass_id], @presented_content[:auth_bypass_ids]
  end

  test "it presents edition links" do
    expected_links = {}
    assert expected_links, @presented_content[:links]
  end
end
