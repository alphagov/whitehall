require "test_helper"
require 'gds_api/test_helpers/publishing_api_v2'

class PublishingApiPresenters::DetailedGuideTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  def present(edition)
    PublishingApiPresenters::DetailedGuide.new(edition)
  end

  test "DetailedGuide presenter passes schema tests" do
    create(:government)
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
    government = create(:government)
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
      schema_name: "detailed_guide",
      document_type: "detailed_guidance",
      locale: "en",
      need_ids: [],
      publishing_app: "whitehall",
      rendering_app: "government-frontend",
      routes: [
        { path: public_path, type: "exact" }
      ],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Some content</p></div>",
        first_public_at: detailed_guide.created_at.iso8601,
        change_history: [],
        tags: {
          browse_pages: [],
          topics: [],
          policies: []
        },
        political: false,
        government: {
          title: government.name,
          slug: government.slug,
          current: government.current?
        },
        related_mainstream_content: [],
        emphasised_organisations: detailed_guide.lead_organisations.map(&:content_id),
      },
    }
    expected_links = {
      organisations: detailed_guide.organisations.map(&:content_id),
      topics: [],
      parent: [],
      related_guides: [],
      related_mainstream: [],
    }
    presented_item = present(detailed_guide)

    assert_equal expected_content.except(:details), presented_item.content.except(:details)
    assert_equivalent_html expected_content[:details].delete(:body), presented_item.content[:details].delete(:body)
    assert_equal expected_content[:details], presented_item.content[:details].except(:body)
    assert_equal expected_links, presented_item.links
    assert_equal detailed_guide.document.content_id, presented_item.content_id
  end

  test 'links hash includes topics and parent if set' do
    edition = create(:detailed_guide)
    create(:specialist_sector, tag: "oil-and-gas/offshore", edition: edition, primary: true)
    create(:specialist_sector, tag: "oil-and-gas/onshore", edition: edition, primary: false)
    publishing_api_has_lookups({
      "/topic/oil-and-gas/offshore" => "content_id_1",
      "/topic/oil-and-gas/onshore" => "content_id_2",
    })

    links = present(edition).links

    assert_equal links[:topics], %w(content_id_1 content_id_2)
    assert_equal links[:parent], %w(content_id_1)
  end

  test 'DetailedGuide presents related_mainstream and related_mainstream_content' do
    lookup_hash = {
      "/guidance/lorem" => "9dd9e077-ae45-45f6-ad9d-2a484e5ff312",
      "/guidance/ipsum" => "9af50189-de1c-49af-a334-6b1d87b593a6"
    }

    publishing_api_has_lookups(lookup_hash)
    create(:government)
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      related_mainstream_content_title: "Lorem",
      related_mainstream_content_url: "http://www.gov.uk/guidance/lorem",
      additional_related_mainstream_content_title: "Ipsum",
      additional_related_mainstream_content_url: "http://www.gov.uk/guidance/ipsum",
    )

    presented_item = present(detailed_guide)
    links = presented_item.links
    details = presented_item.content[:details]
    expected_ids = [
      "9dd9e077-ae45-45f6-ad9d-2a484e5ff312",
      "9af50189-de1c-49af-a334-6b1d87b593a6"
    ]

    # Links can come in any order, so we sort to make sure the set is the same.
    assert_equal expected_ids.sort, links[:related_mainstream].sort

    # Details should respect the specified order.
    assert_equal expected_ids, details[:related_mainstream_content]
  end

  test 'DetailedGuide presents related_mainstream with dodgy data' do
    lookup_hash = {
      "/guidance/lorem" => "cd7fde45-5f79-4982-8939-cedc4bed161c"
    }
    publishing_api_has_lookups(lookup_hash)

    create(:government)
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      related_mainstream_content_title: "Lorem",
      related_mainstream_content_url: "http://www.gov.uk/guidance/lorem?query=string"
    )

    presented_item = present(detailed_guide)
    links = presented_item.links
    expected_ids = ["cd7fde45-5f79-4982-8939-cedc4bed161c"]

    assert_equal expected_ids.sort, links[:related_mainstream].sort
  end

  test 'DetailedGuide does not present related_mainstream with invalid data' do
    lookup_hash = {}
    publishing_api_has_lookups(lookup_hash)

    create(:government)
    detailed_guide = create(
      :detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      related_mainstream_content_title: "Lorem",
      related_mainstream_content_url: "http://www.gov.uk/guidance/lorem",
      additional_related_mainstream_content_title: "Ipsum",
      additional_related_mainstream_content_url: "http://www.whatever.uk/guidance/ipsum",
    )

    presented_item = present(detailed_guide)
    links = presented_item.links
    expected_ids = []

    assert_equal expected_ids.sort, links[:related_mainstream].sort
  end

  test 'DetailedGuide presents political information correctly' do
    government = create(:government)
    detailed_guide = create(
      :published_detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      political: true
    )

    presented_item = present(detailed_guide)
    details = presented_item.content[:details]

    expected_government = {
      title: government.name,
      slug: government.slug,
      current: government.current?
    }
    assert_equal details[:political], true
    assert_equal details[:government], expected_government
  end

  test 'DetailedGuide presents related_guides correctly' do
    create(:government)
    some_detailed_guide = create(:published_detailed_guide)
    detailed_guide = create(
      :published_detailed_guide,
      title: "Some detailed guide",
      summary: "Some summary",
      body: "Some content",
      related_editions: [some_detailed_guide]
    )

    presented_item = present(detailed_guide)
    related_guides = presented_item.links[:related_guides]

    expected_related_guides = [
      some_detailed_guide.content_id
    ]

    assert_equal related_guides, expected_related_guides
  end

  test 'DetailedGuide presents withdrawn_notice correctly' do
    create(:government)
    detailed_guide = create(
      :published_detailed_guide,
      :withdrawn,
    )
    detailed_guide.build_unpublishing(
      unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
      explanation: 'No longer relevant'
    )
    detailed_guide.unpublishing.save!

    presented_item = present(detailed_guide)
    details = presented_item.content[:details]

    expected_withdrawn_notice = {
      explanation: "<div class=\"govspeak\"><p>No longer relevant</p></div>",
      withdrawn_at: detailed_guide.updated_at
    }

    assert_valid_against_schema(presented_item.content, 'detailed_guide')
    assert_equal expected_withdrawn_notice[:withdrawn_at], details[:withdrawn_notice][:withdrawn_at]
    assert_equal expected_withdrawn_notice[:withdrawn_at], presented_item.content[:withdrawn_notice][:withdrawn_at]
    assert_equivalent_html expected_withdrawn_notice[:explanation], details[:withdrawn_notice][:explanation]
    assert_equivalent_html expected_withdrawn_notice[:explanation], presented_item.content[:withdrawn_notice][:explanation]
  end

  test 'DetailedGuide presents national_applicability correctly when some are specified' do
    scotland_nation_inapplicability = create(
      :nation_inapplicability,
      nation: Nation.scotland,
      alternative_url: "http://scotland.com"
    )
    create(:government)
    detailed_guide = create(
      :published_detailed_guide,
      nation_inapplicabilities: [
        scotland_nation_inapplicability
      ]
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

    assert_valid_against_schema(presented_item.content, 'detailed_guide')
    assert_equal expected_national_applicability, details[:national_applicability]
  end
end
