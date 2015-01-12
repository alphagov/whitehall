require 'test_helper'

class PublishingApiPresenters::CaseStudyTest < ActiveSupport::TestCase

  def present(edition)
    PublishingApiPresenters::CaseStudy.new(edition).as_json
  end

  test "case study presentation includes the correct values" do
    case_study = create(:published_case_study,
                    title: 'Case study title',
                    summary: 'The summary',
                    body: 'Some content')

    public_path = Whitehall.url_maker.public_document_path(case_study)
    expected_hash = {
      content_id: case_study.document.content_id,
      title: 'Case study title',
      description: 'The summary',
      base_path: public_path,
      format: 'case_study',
      locale: 'en',
      need_ids: [],
      public_updated_at: case_study.public_timestamp,
      update_type: 'major',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
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
          { public_timestamp: case_study.public_timestamp, note: 'change-note' }
        ],
        tags: {
          browse_pages: [],
          topics: []
        }
      },
      links: {
        lead_organisations: [case_study.lead_organisations.first.content_id],
        related_policies: [],
        supporting_organisations: [],
        world_locations: [],
        worldwide_organisations: [],
        worldwide_priorities: [],
      }
    }
    presented_hash = present(case_study)

    assert_valid_against_schema(presented_hash, 'case_study')

    assert_equal expected_hash.except(:details),
      presented_hash.except(:details)

    # We test for HTML equivlance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_hash[:details].delete(:body),
      presented_hash[:details].delete(:body)

    assert_equal expected_hash[:details], presented_hash[:details]
  end

  test "includes details of the case study image if present" do
    image = build(:image, alt_text: 'Image alt text', caption: 'A caption')
    case_study = create(:published_case_study, images: [image])

    expected_hash = {
      url: (Whitehall.asset_root + image.url(:s300)),
      alt_text: image.alt_text,
      caption: image.caption
    }
    presented_hash = present(case_study)

    assert_valid_against_schema(presented_hash, 'case_study')
    assert_equal expected_hash, presented_hash[:details][:image]
  end

  test "falls back to the organisation's default news image when there is no image" do
    organisation_image = DefaultNewsOrganisationImageData.new(file: image_fixture_file)
    organisation = create(:organisation, default_news_image: organisation_image)

    case_study = create(:published_case_study, lead_organisations: [organisation])

    expected_hash = {
      url: (Whitehall.asset_root + organisation_image.file.url(:s300)),
      alt_text: 'placeholder',
      caption: nil
    }
    presented_hash = present(case_study)

    assert_valid_against_schema(presented_hash, 'case_study')
    assert_equal expected_hash, presented_hash[:details][:image]
  end

  test "links hash includes lead and supporting organisations in correct order" do
    lead_org_1 = create(:organisation)
    lead_org_2 = create(:organisation)
    supporting_org = create(:organisation)
    case_study = create(:published_case_study,
                        lead_organisations: [lead_org_1, lead_org_2],
                        supporting_organisations: [supporting_org])
    presented_hash = present(case_study)
    expected_links_hash = {
      lead_organisations: [lead_org_1.content_id, lead_org_2.content_id],
      related_policies: [],
      supporting_organisations: [supporting_org.content_id],
      world_locations: [],
      worldwide_organisations: [],
      worldwide_priorities: [],
    }

    assert_valid_against_schema(presented_hash, 'case_study')
    assert_equal expected_links_hash, presented_hash[:links]
  end

  test "links hash includes full document history" do
    original_timestamp = 2.days.ago
    original = create(:superseded_case_study, first_published_at: original_timestamp)
    new_timestamp = Time.zone.now
    new_edition = create(:published_case_study, document: original.document, published_major_version: 2, change_note: "More changes", major_change_published_at: new_timestamp)
    presented_hash = present(new_edition)
    assert_valid_against_schema(presented_hash, 'case_study')
    presented_history = presented_hash[:details][:change_history]
    expected_history = [
      { public_timestamp: new_timestamp, note: "More changes" },
      { public_timestamp: original_timestamp, note: "change-note" }
    ]
    assert_equal expected_history, presented_history
  end

  test "links hash includes world locations" do
    location = create(:world_location)
    case_study = create(:published_case_study,
                        world_locations: [location])
    presented_hash = present(case_study)
    assert_valid_against_schema(presented_hash, 'case_study')
    assert_equal [location.content_id], presented_hash[:links][:world_locations]
  end

  test "links hash includes worldwide organisations" do
    wworg = create(:worldwide_organisation)
    case_study = create(:published_case_study,
                        worldwide_organisations: [wworg])
    presented_hash = present(case_study)
    assert_valid_against_schema(presented_hash, 'case_study')
    assert_equal [wworg.content_id], presented_hash[:links][:worldwide_organisations]
  end

  test "links hash includes related policies" do
    policy = create(:policy)
    case_study = create(:published_case_study, related_policies: [policy])
    presented_hash = present(case_study)

    assert_valid_against_schema(presented_hash, 'case_study')
    assert_equal [policy.content_id], presented_hash[:links][:related_policies]
  end

  test "links hash includes worldwide priorities" do
    priority = create(:worldwide_priority)
    case_study = create(:published_case_study, worldwide_priorities: [priority])
    presented_hash = present(case_study)

    assert_valid_against_schema(presented_hash, 'case_study')
    assert_equal [priority.content_id], presented_hash[:links][:worldwide_priorities]
  end

  test "an archived case study includes details of the archive notice" do
    case_study = create(:published_case_study, :archived)
    case_study.build_unpublishing(
      unpublishing_reason_id: UnpublishingReason::Archived.id,
      explanation: 'No longer relevant')

    case_study.unpublishing.save!

    archive_notice = {
      explanation: "<div class=\"govspeak\"><p>No longer relevant</p></div>",
      archived_at: case_study.updated_at
    }

    assert_valid_against_schema(present(case_study), 'case_study')
    assert_equal archive_notice[:archived_at], present(case_study)[:details][:archive_notice][:archived_at]
    assert_equivalent_html archive_notice[:explanation],
      present(case_study)[:details][:archive_notice][:explanation]
  end
end
