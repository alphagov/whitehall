require "test_helper"

class PublishingApi::LandingPagePresenterTest < ActiveSupport::TestCase
  setup do
    @landing_page = create(
      :landing_page,
      document: create(:document, id: 12_345, slug: "/landing-page/test"),
      title: "Landing Page title",
      summary: "Landing Page summary",
      attachments: [create(:file_attachment)],
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

  test "it presents attachments" do
    attachment = @landing_page.attachments.first
    assert_equal attachment.id.to_s, @presented_content.dig(:details, :attachments, 0, :id)
  end

  test "it merges its data with a document using extends:" do
    create(
      :landing_page,
      document: create(:document, id: 12_346, slug: "/landing-page/parent"),
      body: "menu: my-menu-data\nblocks:\n- type: govspeak\n  content: goodbye!",
      title: "Landing Page Parent title",
      summary: "Landing Page Parent summary",
      first_published_at: @first_published_at = Time.zone.now,
      updated_at: 1.year.ago,
    )

    landing_page = create(
      :landing_page,
      document: create(:document, id: 12_347, slug: "/landing-page/extends-test"),
      body: "extends: /landing-page/parent\nblocks:\n- type: govspeak\n  content: hello!",
      title: "Landing Page title",
      summary: "Landing Page summary",
      first_published_at: @first_published_at = Time.zone.now,
      updated_at: 1.year.ago,
    )

    presented_landing_page = PublishingApi::LandingPagePresenter.new(landing_page)
    presented_content = I18n.with_locale("en") { presented_landing_page.content }

    expected_details = {
      "menu" => "my-menu-data",
      "blocks" => [
        { "type" => "govspeak", "content" => "hello!" },
      ],
      "attachments" => [],
    }

    assert_equal expected_details, presented_content[:details].deep_stringify_keys
  end

  test "it recursively expands images in the body" do
    body = <<~YAML
      blocks:
      - type: hero
        image:
          sources:
            desktop: "[Image: hero_image_desktop_2x.png]"
            tablet: "[Image: hero_image_tablet_2x.png]"
            mobile: "[Image: hero_image_mobile_2x.png]"
        hero_content:
          blocks:
          - type: govspeak
            content: "some content"
      - type: grid_container
        blocks:
        - type: hero
          image:
            sources:
              desktop: "[Image: hero_image_desktop_2x.png]"
              tablet: "[Image: hero_image_tablet_2x.png]"
              mobile: "[Image: hero_image_mobile_2x.png]"
          hero_content:
            blocks:
            - type: image
              image:
                sources:
                  desktop: "[Image: landing_page_image.png]"
                  tablet: "[Image: landing_page_image.png]"
                  mobile: "[Image: landing_page_image.png]"
    YAML

    landing_page = create(
      :landing_page,
      document: create(:document, id: 12_346, slug: "/landing-page/with-images"),
      body:,
      title: "Landing Page title",
      summary: "Landing Page summary",
      first_published_at: @first_published_at = Time.zone.now,
      updated_at: 1.year.ago,
      images: [
        build(:image, image_data: build(:hero_image_data, image_kind: "hero_desktop", file: upload_fixture("hero_image_desktop_2x.png", "image/png"))),
        build(:image, image_data: build(:hero_image_data, image_kind: "hero_tablet", file: upload_fixture("hero_image_tablet_2x.png", "image/png"))),
        build(:image, image_data: build(:hero_image_data, image_kind: "hero_mobile", file: upload_fixture("hero_image_mobile_2x.png", "image/png"))),
        build(:image, image_data: build(:landing_page_image_data, file: upload_fixture("landing_page_image.png", "image/png"))),
      ],
    )

    presented_landing_page = PublishingApi::LandingPagePresenter.new(landing_page)
    presented_content = I18n.with_locale("en") { presented_landing_page.content }

    assert_pattern do
      presented_content[:details].deep_symbolize_keys => {
      blocks: [
        {
          type: "hero",
          image: {
            sources: {
              desktop_2x: "http://asset-manager/hero_desktop_2x",
              desktop: "http://asset-manager/hero_desktop_1x",
              tablet_2x: "http://asset-manager/hero_tablet_2x",
              tablet: "http://asset-manager/hero_tablet_1x",
              mobile_2x: "http://asset-manager/hero_mobile_2x",
              mobile: "http://asset-manager/hero_mobile_1x",
            }
          },
          hero_content: {
            blocks: [ { type: "govspeak", content: String } ]
          }
        },
        {
          type: "grid_container",
          blocks: [{
            type: "hero",
            image: {
              sources: {
                desktop_2x: "http://asset-manager/hero_desktop_2x",
                desktop: "http://asset-manager/hero_desktop_1x",
                tablet_2x: "http://asset-manager/hero_tablet_2x",
                tablet: "http://asset-manager/hero_tablet_1x",
                mobile_2x: "http://asset-manager/hero_mobile_2x",
                mobile: "http://asset-manager/hero_mobile_1x",
              }
            },
            hero_content: {
              blocks: [{
                type: "image",
                image: {
                  sources: {
                    desktop_2x: "http://asset-manager/landing_page_desktop_2x",
                    desktop: "http://asset-manager/landing_page_desktop_1x",
                    tablet_2x: "http://asset-manager/landing_page_tablet_2x",
                    tablet: "http://asset-manager/landing_page_tablet_1x",
                    mobile_2x: "http://asset-manager/landing_page_mobile_2x",
                    mobile: "http://asset-manager/landing_page_mobile_1x",
                  }
                },
              }]
            }
          }],
        },
      ]}
    end
  end

  test "raises errors if files are not found" do
    body = <<~YAML
      blocks:
      - type: hero
        image:
          sources:
            desktop: "[Image: non-existent-file.jpg]"
            tablet: "[Image: non-existent-file.jpg]"
            mobile: "[Image: non-existent-file.jpg]"
        hero_content:
          blocks:
          - type: some-block-type
    YAML

    landing_page = build(
      :landing_page,
      document: create(:document, id: 12_346, slug: "/landing-page/with-images"),
      body:,
      title: "Landing Page title",
      summary: "Landing Page summary",
      first_published_at: @first_published_at = Time.zone.now,
      updated_at: 1.year.ago,
      images: [],
    )

    presented_landing_page = PublishingApi::LandingPagePresenter.new(landing_page)
    assert_raises(StandardError, match: /cannot present invalid body/) do
      I18n.with_locale("en") { presented_landing_page.content }
    end
  end

  test "it presents errors if image kinds don't match up" do
    body = <<~YAML
      blocks:
      - type: hero
        image:
          sources:
            desktop: "[Image: hero_image_mobile_2x.png]" # NOTE - using mobile image for desktop field
            tablet: "[Image: hero_image_desktop_2x.png]" # NOTE - using desktop image for tablet field
            mobile: "[Image: hero_image_tablet_2x.png]" # NOTE - using tablet image for desktop field
        hero_content:
          blocks:
          - type: some-block-type
    YAML

    landing_page = build(
      :landing_page,
      document: create(:document, id: 12_346, slug: "/landing-page/with-images"),
      body:,
      title: "Landing Page title",
      summary: "Landing Page summary",
      first_published_at: @first_published_at = Time.zone.now,
      updated_at: 1.year.ago,
      images: [
        build(:image, image_data: build(:hero_image_data, image_kind: "hero_desktop", file: upload_fixture("hero_image_desktop_2x.png", "image/png"))),
        build(:image, image_data: build(:hero_image_data, image_kind: "hero_tablet", file: upload_fixture("hero_image_tablet_2x.png", "image/png"))),
        build(:image, image_data: build(:hero_image_data, image_kind: "hero_mobile", file: upload_fixture("hero_image_mobile_2x.png", "image/png"))),
      ],
    )

    presented_landing_page = PublishingApi::LandingPagePresenter.new(landing_page)
    assert_raises(StandardError, match: /cannot present invalid body/) do
      I18n.with_locale("en") { presented_landing_page.content }
    end
  end
end
