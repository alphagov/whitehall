require "test_helper"

class PublishingApi::TakePartPresenterTest < ActiveSupport::TestCase
  def present(record)
    PublishingApi::TakePartPresenter.new(record)
  end

  test "take part presentation includes the correct values" do
    take_part_page = create(:take_part_page, content_id: SecureRandom.uuid)

    image_url = take_part_page.image.url(:s300)

    expected_hash = {
      base_path: "/government/get-involved/take-part/#{take_part_page.slug}",
      title: "A take part page title",
      description: "Summary text",
      schema_name: "take_part",
      document_type: "take_part",
      locale: "en",
      public_updated_at: take_part_page.updated_at,
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "government-frontend",
      routes: [
        { path: "/government/get-involved/take-part/#{take_part_page.slug}", type: "exact" },
      ],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Some govspeak body text</p></div>",
        image: {
          url: image_url,
          alt_text: "Image alt text",
        },
        ordering: 1,
      },
      update_type: "major",
    }

    presented_item = present(take_part_page)
    presented_content = presented_item.content

    assert_valid_against_publisher_schema(presented_content, "take_part")
    assert_valid_against_links_schema({ links: presented_item.links }, "take_part")

    # We test for HTML equivalance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_hash[:details].delete(:body),
                           presented_content[:details].delete(:body)

    assert_equal expected_hash, presented_content
  end

  test "sends a placeholder url if image variants are missing" do
    take_part_page = build(:take_part_page)
    take_part_page.image.assets = []
    take_part_page.save!

    presented_item = present(take_part_page)

    assert_match(/placeholder.jpg$/, presented_item.content.dig(:details, :image, :url))
  end
end
