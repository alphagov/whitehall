require 'test_helper'

class PublishingApi::CaseStudyPresenterTest < ActiveSupport::TestCase
  def present(edition)
    PublishingApi::CaseStudyPresenter.new(edition)
  end

  test "case study presentation includes the correct values" do
    case_study = create(
      :published_case_study,
      title: 'Case study title',
      summary: 'The summary',
      body: 'Some content',
    )
    public_path = Whitehall.url_maker.public_document_path(case_study)
    expected_content = {
      base_path: public_path,
      title: 'Case study title',
      description: 'The summary',
      schema_name: 'case_study',
      document_type: 'case_study',
      locale: 'en',
      public_updated_at: case_study.public_timestamp,
      publishing_app: 'whitehall',
      rendering_app: 'government-frontend',
      routes: [
        { path: public_path, type: 'exact' }
      ],
      update_type: "major",
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Some content</p></div>",
        format_display_type: 'case_study',
        first_public_at: case_study.first_public_at,
        change_history: [
          { public_timestamp: case_study.public_timestamp, note: 'change-note' }.as_json
        ],
        tags: {
          browse_pages: [],
          topics: [],
          policies: []
        },
        emphasised_organisations: case_study.lead_organisations.map(&:content_id),
      },
    }
    expected_links = {
      organisations: case_study.lead_organisations.map(&:content_id),
      related_policies: [],
      topics: [],
      parent: [],
      world_locations: [],
      worldwide_organisations: [],
    }

    presented_item = present(case_study)

    assert_valid_against_schema(presented_item.content, 'case_study')
    assert_valid_against_links_schema({ links: presented_item.links }, 'case_study')
    assert_equal expected_content.except(:details), presented_item.content.except(:details)
    # We test for HTML equivalance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html(
      expected_content[:details].delete(:body),
      presented_item.content[:details].delete(:body)
    )
    assert_equal expected_content[:details], presented_item.content[:details].except(:body)
    assert_hash_includes presented_item.links, expected_links
    assert_equal case_study.document.content_id, presented_item.content_id
  end

  test "includes details of the case study image if present" do
    image = build(:image, alt_text: 'Image alt text', caption: 'A caption')
    case_study = create(:published_case_study, images: [image])

    expected_hash = {
      url: image.url(:s300),
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
      url: image.url(:s300),
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
      url: organisation_image.file.url(:s300),
      alt_text: 'placeholder',
      caption: nil
    }
    presented_item = present(case_study)

    assert_valid_against_schema(presented_item.content, 'case_study')
    assert_equal expected_hash, presented_item.content[:details][:image]
  end

  test 'links hash includes topics and parent if set' do
    edition = create(:published_case_study)
    create(:specialist_sector, topic_content_id: "content_id_1", edition: edition, primary: true)
    create(:specialist_sector, topic_content_id: "content_id_2", edition: edition, primary: false)

    links = present(edition).links

    assert_equal links[:topics], %w(content_id_1 content_id_2)
    assert_equal links[:parent], %w(content_id_1)
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
      organisations: [lead_org_1.content_id, lead_org_2.content_id, supporting_org.content_id],
      related_policies: [],
      topics: [],
      parent: [],
      world_locations: [],
      worldwide_organisations: [],
    }

    assert_valid_against_links_schema({ links: presented_item.links }, 'case_study')
    assert_hash_includes presented_item.links, expected_links_hash
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

  test "an unpublished document has a first_public_at of the document creation time" do
    case_study = create(:draft_case_study)
    presented_item = present(case_study)
    assert_equal case_study.document.created_at.iso8601, presented_item.content[:details][:first_public_at]
  end
end
