require "test_helper"

class PublishingApiPresenters::DetailedGuideTest < ActiveSupport::TestCase
  def present(edition)
    PublishingApiPresenters::DetailedGuide.new(edition)
  end

  test "DetailedGuide presenter passes schema tests" do
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content"
    )

    presented_item = present(detailed_guide)

    assert_valid_against_schema(presented_item.content, "detailed_guide")
    assert_valid_against_links_schema({ links: presented_item.links }, "detailed_guide")
  end

  test "DetailedGuide presents correct information" do
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content"
    )

    public_path = Whitehall.url_maker.public_document_path(detailed_guide)
    expected_content = {
      base_path: public_path,
      title: "Some detailed guide",
      description: "Some summary",
      public_updated_at: detailed_guide.updated_at,
      format: "detailed_guide",
      locale: "en",
      need_ids: [],
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      routes: [
        { path: public_path, type: "exact" }
      ],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Some content</p></div>",
        first_public_at: detailed_guide.created_at.iso8601,
        change_note: nil,
        change_history: [],
        tags: {
          browse_pages: [],
          topics: [],
          policies: []
        }
      }
    }
    expected_links = {
      lead_organisations: [detailed_guide.lead_organisations.first.content_id],
      related_guides: [],
    }
    presented_item = present(detailed_guide)

    assert_equal expected_content.except(:details), presented_item.content.except(:details)
    assert_equivalent_html expected_content[:details].delete(:body), presented_item.content[:details].delete(:body)
    assert_equal expected_content[:details], presented_item.content[:details].except(:body)
    assert_equal expected_links, presented_item.links
    assert_equal detailed_guide.document.content_id, presented_item.content_id
  end
end
