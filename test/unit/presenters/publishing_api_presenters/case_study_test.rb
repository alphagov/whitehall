require 'test_helper'

class PublishingApiPresenters::CaseStudyTest < ActiveSupport::TestCase

  def present(edition)
    PublishingApiPresenters::CaseStudy.new(edition).as_json
  end

  test "presenter generates valid JSON according to the schema" do
    case_study = create(:published_case_study)
    presented_json = present(case_study).to_json

    assert_valid_against_schema('case_study', presented_json)
  end

  test "case study presentation includes the correct values" do
    case_study = create(:published_case_study,
                    title: 'Case study title',
                    summary: 'The summary',
                    body: 'Some content')

    public_path = Whitehall.url_maker.public_document_path(case_study)
    expected_hash = {
      title: 'Case study title',
      description: 'The summary',
      base_path: public_path,
      format: 'case_study',
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
        supporting_organisations: [],
      }
    }
    presented_hash = present(case_study)

    assert_equal_hash expected_hash.except(:details),
      presented_hash.except(:details)

    # We test for HTML equivlance rather than string equality to get around
    # inconsistencies with line breaks between different XML libraries
    assert_equivalent_html expected_hash[:details].delete(:body),
      presented_hash[:details].delete(:body)

    assert_equal_hash expected_hash[:details], presented_hash[:details]
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

    assert_valid_against_schema('case_study', presented_hash.to_json)
    assert_equal_hash expected_hash, presented_hash[:details][:image]
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

    assert_valid_against_schema('case_study', presented_hash.to_json)
    assert_equal_hash expected_hash, presented_hash[:details][:image]
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
      supporting_organisations: [supporting_org.content_id]
    }

    assert_valid_against_schema('case_study', presented_hash.to_json)
    assert_equal_hash expected_links_hash, presented_hash[:links]
  end

  test "links hash includes full document history" do
    original_timestamp = 2.days.ago
    original = create(:superseded_case_study, first_published_at: original_timestamp)
    new_timestamp = Time.zone.now
    new_edition = create(:published_case_study, document: original.document, published_major_version: 2, change_note: "More changes", major_change_published_at: new_timestamp)
    presented_hash = present(new_edition)
    assert_valid_against_schema('case_study', presented_hash.to_json)
    presented_history = presented_hash[:details][:change_history]
    expected_history = [
      { public_timestamp: new_timestamp, note: "More changes" },
      { public_timestamp: original_timestamp, note: "change-note" }
    ]
    assert_equal expected_history, presented_history
  end

private

  def assert_equal_hash(expected, actual)
    assert_equal expected, actual,
      "Hashes do not match. Differences are:\n\n#{mu_pp(expected.diff(actual))}\n"
  end

  def assert_valid_against_schema(schema_name, json)
    validator = GovukContentSchema::Validator.new(schema_name, json)
    assert validator.valid?, "JSON not valid against #{schema_name} schema: #{validator.errors.to_s}"
  end
end
