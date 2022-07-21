require "test_helper"

class PublishingApi::OrganisationPresenterTest < ActionView::TestCase
  def present(...)
    PublishingApi::OrganisationPresenter.new(...)
  end

  def govspeak_to_html(govspeak)
    Whitehall::GovspeakRenderer.new.govspeak_to_html(govspeak)
  end

  test "presents an organisation with a brand colour" do
    organisation = create(:organisation, organisation_brand_colour_id: 1)
    presented_item = present(organisation)

    assert_equal presented_item.content[:details][:brand], organisation.organisation_brand_colour.class_name
  end

  test "presents an Organisation ready for adding to the publishing API" do
    parent_organisation = create(:organisation, name: "Department for Stuff")
    news_image = create(:default_news_organisation_image_data)
    organisation = create(
      :organisation,
      name: "Organisation of Things",
      analytics_identifier: "O123",
      parent_organisations: [parent_organisation],
      url: "https://www.gov.uk/oot",
      important_board_members: 5,
      default_news_image: news_image,
    )
    create(
      :about_corporate_information_page,
      organisation: organisation,
      summary: "This org is a thing!",
    )
    role = create(:role, organisations: [organisation])
    minister = create(:person)
    create(:ministerial_role_appointment, role: role, person: minister)

    public_path = Whitehall.url_maker.organisation_path(organisation)
    public_atom_path = "#{public_path}.atom"

    expected_hash = {
      base_path: public_path,
      title: "Organisation of Things",
      description: "This org is a thing! Organisation of Things works with the Department for Stuff .",
      schema_name: "organisation",
      document_type: "organisation",
      locale: "en",
      publishing_app: "whitehall",
      rendering_app: "collections",
      routes: [
        { path: public_path, type: "exact" },
        { path: public_atom_path, type: "exact" },
      ],
      redirects: [],
      update_type: "major",
      details: {
        acronym: nil,
        alternative_format_contact_email: nil,
        body: govspeak_to_html("This org is a thing!\n\nOrganisation of Things works with the <a class=\"brand__color\" href=\"/government/organisations/department-for-stuff\">Department for Stuff</a>."),
        brand: nil,
        logo: {
          formatted_title: "Organisation<br/>of<br/>Things",
          crest: "single-identity",
        },
        foi_exempt: false,
        ordered_corporate_information_pages: [
          {
            title: "Jobs",
            href: "https://www.civilservicejobs.service.gov.uk/csr",
          },
        ],
        secondary_corporate_information_pages: "",
        ordered_featured_links: [],
        ordered_featured_documents: [],
        ordered_promotional_features: [],
        important_board_members: 5,
        organisation_featuring_priority: "news",
        organisation_govuk_status: {
          status: "live",
          url: nil,
          updated_at: nil,
        },
        organisation_type: "other",
        organisation_political: false,
        social_media_links: [],
        default_news_image: {
          url: news_image.file.url(:s300),
          high_resolution_url: news_image.file.url(:s960),
        },
      },
      analytics_identifier: "O123",
    }
    expected_links = {
      ordered_contacts: [],
      ordered_foi_contacts: [],
      ordered_high_profile_groups: [],
      ordered_parent_organisations: [parent_organisation.content_id],
      ordered_child_organisations: [],
      ordered_successor_organisations: [],
      ordered_ministers: [minister.content_id],
      ordered_roles: [role.content_id],
      primary_publishing_organisation: [organisation.content_id],
    }

    presented_item = present(organisation)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal organisation.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "organisation")
  end

  test "presents an organisation’s custom logo" do
    organisation = create(
      :organisation,
      name: "Organisation of Things",
      organisation_logo_type_id: 14,
      logo: upload_fixture("images/960x640_jpeg.jpg", "image/jpeg"),
    )
    presented_item = present(organisation)

    expected_image_url = "https://static.test.gov.uk" \
      "/government/uploads/system/uploads/organisation/logo/#{organisation.logo.model.id}/960x640_jpeg.jpg"

    assert_equal(
      {
        url: expected_image_url,
        alt_text: "Organisation of Things",
      },
      presented_item.content[:details][:logo][:image],
    )
  end

  test "presents an organisation with a custom logo with a nil crest" do
    organisation = create(
      :organisation,
      name: "Organisation of Things",
      organisation_logo_type_id: 14,
      logo: upload_fixture("images/960x640_jpeg.jpg", "image/jpeg"),
    )
    presented_item = present(organisation)

    assert_nil presented_item.content[:details][:logo][:crest]
  end

  test "presents an organisation with no identity with a nil crest" do
    organisation = create(
      :organisation,
      name: "Organisation of Things",
      organisation_logo_type_id: 1,
    )
    presented_item = present(organisation)

    assert_nil presented_item.content[:details][:logo][:crest]
  end

  test "presents an organisation with no parents/children without the relationship text" do
    organisation = create(
      :organisation,
      name: "Organisation of Things",
    )
    presented_item = present(organisation)

    assert_equal(govspeak_to_html(""), presented_item.content[:details][:body])
  end

  test "presents an eligible organisation with promotional features" do
    promotional_feature = create(:promotional_feature)
    organisation = create(
      :organisation,
      name: "Organisation of Things",
      organisation_type: OrganisationType.executive_office,
      promotional_features: [promotional_feature],
    )
    presented_item = present(organisation)

    assert_equal(
      [
        {
          title: promotional_feature.title,
          items: [],
        },
      ],
      presented_item.content[:details][:ordered_promotional_features],
    )
  end

  test "does not present an ineligible organisation with promotional features" do
    promotional_feature = create(:promotional_feature)
    organisation = create(
      :organisation,
      name: "Organisation of Things",
      organisation_type: OrganisationType.ministerial_department,
      promotional_features: [promotional_feature],
    )
    presented_item = present(organisation)

    assert_equal([], presented_item.content[:details][:ordered_promotional_features])
  end

  test "presents the current/new URL for a non-live organisation" do
    organisation = create(
      :organisation,
      name: "Organisation of Things",
      govuk_status: "exempt",
      url: "http://www.example.com/org-of-things",
    )
    presented_item = present(organisation)

    assert_equal("http://www.example.com/org-of-things", presented_item.content[:details][:organisation_govuk_status][:url])
  end

  test "uses the about page body for courts and tribunals" do
    organisation = create(
      :court,
      name: "Court and bowled",
    )
    def organisation.body
      "Habeus corpus"
    end

    presented_item = present(organisation)

    assert_equal("<div class=\"govspeak\"><p>Habeus corpus</p>\n</div>", presented_item.content[:details][:body])
  end

  test "uses the about page summary for other orgs" do
    organisation = create(
      :organisation,
      name: "Ministry of sound",
    )
    def organisation.summary
      "Habeus loudius noisus"
    end

    presented_item = present(organisation)

    assert_equal("<div class=\"govspeak\"><p>Habeus loudius noisus</p>\n</div>", presented_item.content[:details][:body])
  end

  test "renders courts and tribunals using Collections" do
    organisation = create(
      :court,
      name: "Court at mid-wicket",
    )
    presented_item = present(organisation)

    assert_equal("collections", presented_item.content[:rendering_app])
    assert_equal([{ path: "/courts-tribunals/court-at-mid-wicket", type: "exact" }], presented_item.content[:routes])
  end

  test "present default news image url only when image is SVG" do
    news_image = create(
      :default_news_organisation_image_data,
      file: File.open(Rails.root.join("test/fixtures/images/test-svg.svg")),
    )
    organisation = create(:organisation, default_news_image: news_image)
    presented_item = present(organisation)
    expected_hash = { url: news_image.file.url }

    assert_equal expected_hash, presented_item.content[:details][:default_news_image]
  end

  test "presents the display type of an offsite link" do
    organisation = create(
      :court,
      name: "An organisation with offsite links",
    )
    offsite_link = create(:offsite_link, link_type: "content_publisher_news_story")
    feature = create(:feature, document: nil, offsite_link: offsite_link)
    create(:feature_list, features: [feature], featurable: organisation)
    presented_item = present(organisation)
    document_type = presented_item.content.dig(:details, :ordered_featured_documents, 0, :document_type)

    assert_equal document_type, offsite_link.display_type
  end

  test "presents the alternative format contact email" do
    organisation = create(
      :organisation,
      alternative_format_contact_email: "foo@bar.com",
    )
    presented_item = present(organisation)
    email = presented_item.content.dig(:details, :alternative_format_contact_email)

    assert_equal email, "foo@bar.com"
  end

  test "presents the organisation's political status" do
    organisation = create(
      :organisation,
      political: true,
    )
    presented_item = present(organisation)
    organisation_political = presented_item.content.dig(:details, :organisation_political)

    assert organisation_political
  end
end
