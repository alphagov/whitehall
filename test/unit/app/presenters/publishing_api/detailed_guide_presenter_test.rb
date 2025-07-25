require "test_helper"
require "gds_api/test_helpers/publishing_api"

class PublishingApi::DetailedGuidePresenterTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApi

  def present(edition)
    edition.auth_bypass_id = "52db85fc-0f30-42a6-afdd-c2b31ecc6a67"
    PublishingApi::DetailedGuidePresenter.new(edition)
  end

  test "DetailedGuide presenter passes schema tests" do
    create(:government)
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
    )

    presented_item = present(detailed_guide)

    assert_valid_against_publisher_schema(presented_item.content, "detailed_guide")
    assert_valid_against_links_schema({ links: presented_item.links }, "detailed_guide")
  end

  test "DetailedGuide presents correct information" do
    government = create(:government)
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
    )

    topical_event = create(:topical_event)
    detailed_guide.topical_event_memberships.create!(topical_event_id: topical_event.id)

    public_path = detailed_guide.public_path
    expected_content = {
      base_path: public_path,
      title: "Some detailed guide",
      description: "Some summary",
      public_updated_at: detailed_guide.updated_at,
      schema_name: "detailed_guide",
      document_type: "detailed_guide",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "frontend",
      routes: [
        { path: public_path, type: "exact" },
      ],
      redirects: [],
      auth_bypass_ids: %w[52db85fc-0f30-42a6-afdd-c2b31ecc6a67],
      update_type: "major",
      details: {
        body: "<div class=\"govspeak\"><p>Some content</p></div>",
        change_history: [],
        tags: {
          browse_pages: [],
        },
        political: false,
        related_mainstream_content: [],
        emphasised_organisations: detailed_guide.lead_organisations.map(&:content_id),
        attachments: [],
      },
      links: {
        organisations: detailed_guide.organisations.map(&:content_id),
        primary_publishing_organisation: [
          detailed_guide.lead_organisations.first.content_id,
        ],
        original_primary_publishing_organisation: [
          detailed_guide.document.editions.first.lead_organisations.first.content_id,
        ],
        related_guides: [],
        related_mainstream_content: [],
        government: [government.content_id],
        topical_events: [topical_event.content_id],
      },
    }
    expected_links = {}
    presented_item = present(detailed_guide)

    assert_equal expected_content.except(:details), presented_item.content.except(:details)
    assert_equivalent_html expected_content[:details].delete(:body), presented_item.content[:details].delete(:body)
    assert_equal expected_content[:details], presented_item.content[:details].except(:body)
    assert_hash_includes presented_item.links, expected_links
    assert_equal detailed_guide.document.content_id, presented_item.content_id
  end

  test "DetailedGuide includes headers when headers are present in body" do
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "##Some header\n\nSome content",
    )

    presented_item = present(detailed_guide)
    details = presented_item.content[:details]

    expected_headers = [
      {
        text: "Some header",
        level: 2,
        id: "some-header",
      },
    ]

    assert_equal expected_headers, details[:headers]
  end

  test "DetailedGuide does not include headers when headers are not present in body" do
    detailed_guide = create(
      :published_detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
    )

    presented_item = present(detailed_guide)
    details = presented_item.content[:details]

    assert_nil details[:headers]
  end

  test "DetailedGuide presents related mainstream in links and details" do
    lookup_hash = {
      "/mainstream-content" => "9dd9e077-ae45-45f6-ad9d-2a484e5ff312",
      "/another-mainstream-content" => "9af50189-de1c-49af-a334-6b1d87b593a6",
    }

    stub_publishing_api_has_lookups(lookup_hash)
    create(:government)
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      related_mainstream_content_url: "http://www.gov.uk/mainstream-content",
      additional_related_mainstream_content_url: "http://www.gov.uk/another-mainstream-content",
    )

    presented_item = present(detailed_guide)
    edition_links = presented_item.edition_links
    details = presented_item.content[:details]

    assert_equal %w[9dd9e077-ae45-45f6-ad9d-2a484e5ff312 9af50189-de1c-49af-a334-6b1d87b593a6], details[:related_mainstream_content]
    assert_equal %w[9dd9e077-ae45-45f6-ad9d-2a484e5ff312 9af50189-de1c-49af-a334-6b1d87b593a6].sort!, edition_links[:related_mainstream_content].sort!
  end

  test "DetailedGuide presents related_mainstream with dodgy data" do
    lookup_hash = {
      "/guidance/lorem" => "cd7fde45-5f79-4982-8939-cedc4bed161c",
    }
    stub_publishing_api_has_lookups(lookup_hash)

    create(:government)
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      related_mainstream_content_title: "Lorem",
      related_mainstream_content_url: "http://www.gov.uk/guidance/lorem?query=string",
    )

    presented_item = present(detailed_guide)
    edition_links = presented_item.edition_links
    expected_ids = %w[cd7fde45-5f79-4982-8939-cedc4bed161c]

    assert_equal expected_ids.sort, edition_links[:related_mainstream_content].sort
  end

  test "DetailedGuide presents political information correctly" do
    government = create(:government)
    detailed_guide = create(
      :published_detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      political: true,
    )

    presented_item = present(detailed_guide)
    details = presented_item.content[:details]

    assert_equal details[:political], true
    assert_equal presented_item.edition_links[:government][0], government.content_id
  end

  test "DetailedGuide presents related_guides correctly" do
    create(:government)
    some_detailed_guide = create(:published_detailed_guide)
    detailed_guide = create(
      :published_detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      related_editions: [some_detailed_guide],
    )

    presented_item = present(detailed_guide)
    related_guides = presented_item.edition_links[:related_guides]

    expected_related_guides = [
      some_detailed_guide.content_id,
    ]

    assert_equal related_guides, expected_related_guides
  end

  test "DetailedGuide presents national_applicability correctly when some are specified" do
    scotland_nation_inapplicability = create(
      :nation_inapplicability,
      nation: Nation.scotland,
      alternative_url: "http://scotland.com",
    )
    create(:government)
    detailed_guide = create(
      :published_detailed_guide_with_excluded_nations,
      nation_inapplicabilities: [
        scotland_nation_inapplicability,
      ],
    )

    presented_item = present(detailed_guide)
    details = presented_item.content[:details]

    expected_national_applicability = {
      england: {
        label: "England",
        applicable: true,
      },
      northern_ireland: {
        label: "Northern Ireland",
        applicable: true,
      },
      scotland: {
        label: "Scotland",
        applicable: false,
        alternative_url: "http://scotland.com",
      },
      wales: {
        label: "Wales",
        applicable: true,
      },
    }

    assert_valid_against_publisher_schema(presented_item.content, "detailed_guide")
    assert_valid_against_links_schema({ links: presented_item.links }, "detailed_guide")
    assert_equal expected_national_applicability, details[:national_applicability]
  end

  test "DetailedGuide presents an image correctly" do
    detailed_guide = create(
      :published_detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      logo_url: "http://www.example.com/foo.jpg",
    )

    presented_item = present(detailed_guide)
    assert_equal "http://www.example.com/foo.jpg", presented_item.content[:details][:image][:url]
  end

  test "DetailedGuide presents attachments" do
    detailed_guide = create(:published_detailed_guide, :with_file_attachment)

    presented_item = present(detailed_guide)
    assert_valid_against_publisher_schema(presented_item.content, "detailed_guide")
    assert_valid_against_links_schema({ links: presented_item.links }, "detailed_guide")
    assert_equal presented_item.content.dig(:details, :attachments, 0, :id),
                 detailed_guide.attachments.first.id.to_s
  end
end
