require 'test_helper'

class PublishingApiPresenters::PublicationTest < ActiveSupport::TestCase
  def present(edition)
    PublishingApiPresenters::Publication.new(edition)
  end

  test "publication presentation includes the correct values" do
    government = create(:government)
    publication = create(:published_publication,
                    title: 'Publication title',
                    summary: 'The summary',
                    body: 'Some content')

    public_path = Whitehall.url_maker.public_document_path(publication)
    expected_content = {
      base_path: public_path,
      title: 'Publication title',
      description: 'The summary',
      schema_name: 'publication',
      document_type: 'policy_paper',
      locale: 'en',
      need_ids: [],
      public_updated_at: publication.public_timestamp,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend', #to be renamed into 'government-frontend'
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Some content</p></div>",
        tags: {
          browse_pages: [],
          policies: [],
          topics: []
        },
        documents: ["<section class=\"attachment embedded\" id=\"attachment_1\">\n  <div class=\"attachment-thumb\">\n      <a aria-hidden=\"true\" class=\"thumbnail\" href=\"/government/publications/publication-title/#{publication.attachments.first.title}\"><img alt=\"\" src=\"/government/assets/pub-cover-html.png\" /></a>\n  </div>\n  <div class=\"attachment-details\">\n    <h2 class=\"title\"><a href=\"/government/publications/publication-title/#{publication.attachments.first.title}\">#{publication.attachments.first.title}</a></h2>\n    <p class=\"metadata\">\n        <span class=\"type\">HTML</span>\n    </p>\n\n\n  </div>\n</section>"],
        first_public_at: publication.first_public_at,
        change_history: [
          { public_timestamp: publication.public_timestamp, note: 'change-note' }.as_json
        ],
        emphasised_organisations: publication.lead_organisations.map(&:content_id),
        political: false,
        government: {
          title: government.name,
          slug: government.slug,
          current: government.current?
        },
      },
    }

    minister = create(:ministerial_role_appointment)
    publication.role_appointments << minister
    topical_event = create(:topical_event)
    publication.classification_memberships.create(classification_id: topical_event.id)

    expected_links = {
      topics: [],
      organisations: publication.lead_organisations.map(&:content_id),
      document_collections: [],
      ministers: [minister.person.content_id],
      related_statistical_data_sets: [],
      world_locations: [],
      topical_events: [topical_event.content_id],
    }

    presented_item = present(publication)

    assert_valid_against_schema(presented_item.content, 'publication')
    assert_valid_against_links_schema({ links: presented_item.links }, 'publication')

    assert_equal expected_content.except(:details),
      presented_item.content.except(:details)

    # We test for HTML equivlance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_content[:details].delete(:body),
      presented_item.content[:details].delete(:body)
    assert_equal expected_content[:details], presented_item.content[:details].except(:body)
    assert_equal expected_links, presented_item.links
    assert_equal publication.document.content_id, presented_item.content_id
  end

  test "links hash includes lead and supporting organisations in correct order" do
    lead_org_1 = create(:organisation)
    lead_org_2 = create(:organisation)
    supporting_org = create(:organisation)
    publication = create(:published_publication,
                        lead_organisations: [lead_org_1, lead_org_2],
                        supporting_organisations: [supporting_org])
    presented_item = present(publication)
    expected_links_hash = {
      topics: [],
      organisations: [lead_org_1.content_id, lead_org_2.content_id, supporting_org.content_id],
      document_collections: [],
      world_locations: [],
      ministers: [],
      related_statistical_data_sets: [],
      topical_events: []
    }

    assert_valid_against_links_schema({ links: presented_item.links }, 'publication')
    assert_equal expected_links_hash, presented_item.links
  end

  test "details hash includes full document history" do
    original_timestamp = 2.days.ago
    original = create(:superseded_publication, first_published_at: original_timestamp)
    new_timestamp = Time.zone.now
    create(:government)
    new_edition = create(:published_publication, document: original.document, published_major_version: 2, change_note: "More changes", major_change_published_at: new_timestamp)
    presented_item = present(new_edition)
    assert_valid_against_schema(presented_item.content, 'publication')
    presented_history = presented_item.content[:details][:change_history]
    expected_history = [
      { public_timestamp: new_timestamp, note: "More changes" },
      { public_timestamp: original_timestamp, note: "change-note" }
    ].as_json
    assert_equal expected_history, presented_history
  end

  test "links hash includes world locations" do
    location = create(:world_location)
    publication = create(:published_publication,
                        world_locations: [location])
    presented_item = present(publication)
    assert_valid_against_links_schema({ links: presented_item.links }, 'publication')
    assert_equal [location.content_id], presented_item.links[:world_locations]
  end

  test "links hash includes document collections that the publication is part of" do
    publication = create(:published_publication)
    document_collections = [
      create(:published_document_collection, groups: [build(:document_collection_group, documents: [publication.document])]),
      create(:published_document_collection, groups: [build(:document_collection_group, documents: [publication.document])])
    ]

    publication.document_collections.reload
    presented_item = present(publication)

    assert_valid_against_links_schema({ links: presented_item.links }, 'publication')
    assert_same_elements document_collections.map(&:content_id), presented_item.links[:document_collections]
  end

  test "a withdrawn publication includes details of the archive notice" do
    create(:government)
    publication = create(:published_publication, :withdrawn)
    publication.build_unpublishing(
      unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
      explanation: 'No longer relevant')

    publication.unpublishing.save!

    archive_notice = {
      explanation: "<div class=\"govspeak\"><p>No longer relevant</p></div>",
      archived_at: publication.updated_at
    }

    presented_item = present(publication)

    assert_valid_against_schema(presented_item.content, 'publication')
    assert_equal archive_notice[:archived_at], presented_item.content[:details][:withdrawn_notice][:withdrawn_at]
    assert_equivalent_html archive_notice[:explanation],
      presented_item.content[:details][:withdrawn_notice][:explanation]
  end

  test "an unpublished document has a first_public_at of the document creation time" do
    create(:government)
    publication = create(:draft_publication)
    presented_item = present(publication)
    assert_equal publication.document.created_at.iso8601, presented_item.content[:details][:first_public_at]
  end
end
