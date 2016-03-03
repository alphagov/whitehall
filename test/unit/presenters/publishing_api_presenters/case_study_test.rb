require 'test_helper'

class PublishingApiPresenters::CaseStudyTest < ActiveSupport::TestCase
  def present(edition)
    PublishingApiPresenters::CaseStudy.new(edition)
  end

  test "case study presentation includes the correct values" do
    case_study = create(:published_case_study,
                    title: 'Case study title',
                    summary: 'The summary',
                    body: 'Some content')

    public_path = Whitehall.url_maker.public_document_path(case_study)
    expected_content = {
      base_path: public_path,
      title: 'Case study title',
      description: 'The summary',
      format: 'case_study',
      locale: 'en',
      need_ids: [],
      public_updated_at: case_study.public_timestamp,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Some content</p></div>",
        format_display_type: 'case_study',
        first_public_at: case_study.first_public_at,
        change_note: nil,
        change_history: [
          { public_timestamp: case_study.public_timestamp, note: 'change-note' }.as_json
        ],
        tags: {
          browse_pages: [],
          topics: [],
          policies: []
        }
      },
    }

    expected_links = {
      document_collections: [],
      lead_organisations: [case_study.lead_organisations.first.content_id],
      related_policies: [],
      supporting_organisations: [],
      topics: [],
      world_locations: [],
      worldwide_organisations: [],
      worldwide_priorities: [],
    }

    presented_item = present(case_study)

    assert_valid_against_schema(presented_item.content, 'case_study')
    assert_valid_against_links_schema({ links: presented_item.links }, 'case_study')

    assert_equal expected_content.except(:details),
      presented_item.content.except(:details)

    # We test for HTML equivlance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_content[:details].delete(:body),
      presented_item.content[:details].delete(:body)

    assert_equal expected_content[:details], presented_item.content[:details].except(:body)
    assert_equal expected_links, presented_item.links
    assert_equal case_study.document.content_id, presented_item.content_id
  end

  test "includes details of the case study image if present" do
    image = build(:image, alt_text: 'Image alt text', caption: 'A caption')
    case_study = create(:published_case_study, images: [image])

    expected_hash = {
      url: (Whitehall.public_asset_host + image.url(:s300)),
      alt_text: image.alt_text,
      caption: image.caption
    }
    presented_item = present(case_study)

    assert_valid_against_schema(presented_item.content, 'case_study')
    assert_equal expected_hash, presented_item.content[:details][:image]
  end

  test "returns case study image caption as nil (not false) when it is blank" do
    image = build(:image, alt_text: 'Image alt text', caption: '')
    case_study = create(:published_case_study, images: [image])

    expected_hash = {
      url: (Whitehall.public_asset_host + image.url(:s300)),
      alt_text: image.alt_text,
      caption: nil
    }
    presented_item = present(case_study)

    assert_valid_against_schema(presented_item.content, 'case_study')
    assert_equal expected_hash, presented_item.content[:details][:image]
  end

  test "falls back to the organisation's default news image when there is no image" do
    organisation_image = DefaultNewsOrganisationImageData.new(file: image_fixture_file)
    organisation = create(:organisation, default_news_image: organisation_image)

    case_study = create(:published_case_study, lead_organisations: [organisation])

    expected_hash = {
      url: (Whitehall.public_asset_host + organisation_image.file.url(:s300)),
      alt_text: 'placeholder',
      caption: nil
    }
    presented_item = present(case_study)

    assert_valid_against_schema(presented_item.content, 'case_study')
    assert_equal expected_hash, presented_item.content[:details][:image]
  end

  test "links hash includes lead and supporting organisations in correct order" do
    lead_org_1 = create(:organisation)
    lead_org_2 = create(:organisation)
    supporting_org = create(:organisation)
    case_study = create(:published_case_study,
                        lead_organisations: [lead_org_1, lead_org_2],
                        supporting_organisations: [supporting_org])
    presented_item = present(case_study)
    expected_links_hash = {
      document_collections: [],
      lead_organisations: [lead_org_1.content_id, lead_org_2.content_id],
      related_policies: [],
      supporting_organisations: [supporting_org.content_id],
      topics: [],
      world_locations: [],
      worldwide_organisations: [],
      worldwide_priorities: [],
    }

    assert_valid_against_links_schema({ links: presented_item.links }, 'case_study')
    assert_equal expected_links_hash, presented_item.links
  end

  test "details hash includes full document history" do
    original_timestamp = 2.days.ago
    original = create(:superseded_case_study, first_published_at: original_timestamp)
    new_timestamp = Time.zone.now
    new_edition = create(:published_case_study, document: original.document, published_major_version: 2, change_note: "More changes", major_change_published_at: new_timestamp)
    presented_item = present(new_edition)
    assert_valid_against_schema(presented_item.content, 'case_study')
    presented_history = presented_item.content[:details][:change_history]
    expected_history = [
      { public_timestamp: new_timestamp, note: "More changes" },
      { public_timestamp: original_timestamp, note: "change-note" }
    ].as_json
    assert_equal expected_history, presented_history
  end

  test "links hash includes world locations" do
    location = create(:world_location)
    case_study = create(:published_case_study,
                        world_locations: [location])
    presented_item = present(case_study)
    assert_valid_against_links_schema({ links: presented_item.links }, 'case_study')
    assert_equal [location.content_id], presented_item.links[:world_locations]
  end

  test "links hash includes worldwide organisations" do
    wworg = create(:worldwide_organisation)
    case_study = create(:published_case_study,
                        worldwide_organisations: [wworg])
    presented_item = present(case_study)
    assert_valid_against_links_schema({ links: presented_item.links }, 'case_study')
    assert_equal [wworg.content_id], presented_item.links[:worldwide_organisations]
  end

  test 'links hash includes related policies' do
    case_study = create(:published_case_study, policy_content_ids: [policy_1["content_id"]])
    presented_item = present(case_study)

    assert_valid_against_links_schema({ links: presented_item.links }, 'case_study')
    assert_equal [policy_area_1["content_id"], policy_1["content_id"]], presented_item.links[:related_policies]
  end

  test "links hash includes worldwide priorities" do
    priority = create(:worldwide_priority)
    case_study = create(:published_case_study)
    priority.document.edition_relations.create!(edition: case_study)
    presented_item = present(case_study)

    assert_valid_against_links_schema({ links: presented_item.links }, 'case_study')
    assert_equal [priority.content_id], presented_item.links[:worldwide_priorities]
  end

  test "links hash includes document collections that the case study is part of" do
    case_study = create(:published_case_study)
    document_collections = [
      create(:published_document_collection, groups: [build(:document_collection_group, documents: [case_study.document])]),
      create(:published_document_collection, groups: [build(:document_collection_group, documents: [case_study.document])])
    ]

    case_study.document_collections.reload
    presented_item = present(case_study)

    assert_valid_against_links_schema({ links: presented_item.links }, 'case_study')
    assert_same_elements document_collections.map(&:content_id), presented_item.links[:document_collections]
  end

  test "a withdrawn case study includes details of the archive notice" do
    case_study = create(:published_case_study, :withdrawn)
    case_study.build_unpublishing(
      unpublishing_reason_id: UnpublishingReason::Withdrawn.id,
      explanation: 'No longer relevant')

    case_study.unpublishing.save!

    archive_notice = {
      explanation: "<div class=\"govspeak\"><p>No longer relevant</p></div>",
      archived_at: case_study.updated_at
    }

    presented_item = present(case_study)

    assert_valid_against_schema(presented_item.content, 'case_study')
    assert_equal archive_notice[:archived_at], presented_item.content[:details][:withdrawn_notice][:withdrawn_at]
    assert_equivalent_html archive_notice[:explanation],
      presented_item.content[:details][:withdrawn_notice][:explanation]
  end

  test "an unpublished document has a first_public_at of the document creation time" do
    case_study = create(:draft_case_study)
    presented_item = present(case_study)
    assert_equal case_study.document.created_at.iso8601, presented_item.content[:details][:first_public_at]
  end
end
