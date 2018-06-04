require 'test_helper'

class PublishingApi::OrganisationPresenterTest < ActionView::TestCase
  def present(model_instance, options = {})
    PublishingApi::OrganisationPresenter.new(model_instance, options)
  end

  test 'presents an organisation with a brand colour' do
    organisation = create(:organisation, organisation_brand_colour_id: 1)
    presented_item = present(organisation)

    assert_equal presented_item.content[:details][:brand], organisation.organisation_brand_colour.class_name
  end

  test 'presents an Organisation ready for adding to the publishing API' do
    organisation = create(:organisation, name: 'Organisation of Things', analytics_identifier: 'O123')
    role = create(:role, organisations: [organisation])
    public_path = Whitehall.url_maker.organisation_path(organisation)

    expected_hash = {
      base_path: public_path,
      title: "Organisation of Things",
      description: nil,
      schema_name: 'organisation',
      document_type: 'organisation',
      links: {
        ordered_contacts: [],
        ordered_foi_contacts: [],
        ordered_featured_policies: [],
        ordered_parent_organisations: [],
        ordered_child_organisations: [],
        ordered_successor_organisations: [],
        ordered_high_profile_groups: [],
      },
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: organisation.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      update_type: "major",
      details: {
        body: "",
        brand: nil,
        logo: {
          formatted_title: "Organisation<br/>of<br/>Things",
          crest: "single-identity",
        },
        foi_exempt: false,
        ordered_corporate_information_pages: [
          {
            title: "Corporate reports",
            href: "/government/publications?departments%5B%5D=organisation-of-things&publication_type=corporate-reports"
          },
          {
            title: "Transparency data",
            href: "/government/publications?departments%5B%5D=organisation-of-things&publication_type=transparency-data"
          },
          {
            title: "Jobs",
            href: "https://www.civilservicejobs.service.gov.uk/csr"
          }
        ],
        ordered_featured_links: [],
        ordered_featured_documents: [],
        ordered_ministers: [],
        ordered_board_members: [],
        ordered_military_personnel: [],
        ordered_traffic_commissioners: [],
        ordered_chief_professional_officers: [],
        ordered_special_representatives: [],
        organisation_featuring_priority: "news",
        organisation_govuk_status: {
          status: "live",
          updated_at: nil,
        },
        organisation_type: "other",
        social_media_links: [],
      },
      analytics_identifier: "O123",
    }
    expected_links = {
      ordered_roles: [role.content_id],
    }

    presented_item = present(organisation)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal organisation.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'organisation')
  end

  test 'presents an organisation’s custom logo' do
    organisation = create(
      :organisation,
      name: 'Organisation of Things',
      organisation_logo_type_id: 14,
      logo: fixture_file_upload('images/960x640_jpeg.jpg', 'image/jpeg')
    )
    presented_item = present(organisation)

    expected_image_url = 'https://static.test.gov.uk' +
      '/government/uploads/system/uploads/organisation/logo/1/960x640_jpeg.jpg'

    assert_equal(
      {
        url: expected_image_url,
        alt_text: 'Organisation of Things',
      },
      presented_item.content[:details][:logo][:image]
    )
  end

  test 'presents an organisation with a custom logo with a nil crest' do
    organisation = create(
      :organisation,
      name: 'Organisation of Things',
      organisation_logo_type_id: 14,
      logo: fixture_file_upload('images/960x640_jpeg.jpg', 'image/jpeg')
    )
    presented_item = present(organisation)

    assert_nil presented_item.content[:details][:logo][:crest]
  end

  test 'presents an organisation with no identity with a nil crest' do
    organisation = create(
      :organisation,
      name: 'Organisation of Things',
      organisation_logo_type_id: 1
    )
    presented_item = present(organisation)

    assert_nil presented_item.content[:details][:logo][:crest]
  end
end
