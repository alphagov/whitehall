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
    news_image = create(:featured_image_data)
    organisation = create(
      :organisation,
      name: "Organisation of Things",
      analytics_identifier: "O123",
      parent_organisations: [parent_organisation],
      url: "https://www.gov.uk/oot",
      default_news_image: news_image,
    )
    create(
      :about_corporate_information_page,
      organisation:,
      summary: "This org is a thing!",
    )
    role = create(:role, organisations: [organisation])
    minister = create(:person)
    create(:ministerial_role_appointment, role:, person: minister)

    public_path = organisation.public_path
    public_atom_path = "#{public_path}.atom"

    expected_hash = {
      base_path: public_path,
      title: "Organisation of Things",
      description: "This org is a thing! Organisation of Things works with the Department for Stuff .",
      schema_name: "organisation",
      document_type: "organisation",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: "collections",
      routes: [
        { path: public_path, type: "prefix" },
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
        ordered_corporate_information_pages: [],
        secondary_corporate_information_pages: "",
        ordered_featured_links: [],
        ordered_featured_documents: [],
        ordered_promotional_features: [],
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
    assert_valid_against_links_schema({ links: presented_item.links }, "organisation")
  end

  test "caps number of featured documents at 6" do
    features = (1..7).to_a.map do |i|
      created_case_study = create(:published_case_study, title: "case-study-#{i}")
      build(:feature, document: created_case_study.document, ordering: i)
    end
    organisation = create(:organisation)

    create(:feature_list, featurable: organisation, features:)

    assert_equal 6, present(organisation).content.dig(:details, :ordered_featured_documents).size
  end

  test "caps number of featured documents at 7 for Number 10" do
    features = (1..8).to_a.map do |i|
      created_case_study = create(:published_case_study, title: "case-study-#{i}")
      build(:feature, document: created_case_study.document, ordering: i)
    end
    organisation = create(:organisation, slug: "prime-ministers-office-10-downing-street")

    create(:feature_list, featurable: organisation, features:)

    assert_equal 7, present(organisation).content.dig(:details, :ordered_featured_documents).size
  end

  test "presents an organisation’s custom logo" do
    organisation = create(
      :organisation_with_logo_and_assets,
      name: "Organisation of Things",
    )
    presented_item = present(organisation)

    expected_image_url = "#{Plek.asset_root}/media/logo_asset_manager_id/minister-of-funk.960x640.jpg"

    assert_equal(
      {
        url: expected_image_url,
        alt_text: "Organisation of Things",
      },
      presented_item.content[:details][:logo][:image],
    )
  end

  test "presents an organisation with a custom logo with a nil crest" do
    organisation = create(:organisation_with_logo_and_assets)
    presented_item = present(organisation)

    assert_nil presented_item.content[:details][:logo][:crest]
  end

  test "filters out logo with no asset variants" do
    organisation = build(:organisation_with_logo_and_assets)
    organisation.assets.delete_all
    presented_item = present(organisation)

    assert_nil presented_item.content[:details][:logo][:image]
  end

  test "presents an organisation with no identity with a nil crest" do
    organisation = create(
      :organisation,
      organisation_logo_type_id: 1,
    )
    presented_item = present(organisation)

    assert_nil presented_item.content[:details][:logo][:crest]
  end

  test "presents an organisation with no parents/children without the relationship text" do
    organisation = create(
      :organisation,
    )
    presented_item = present(organisation)

    assert_equal(govspeak_to_html(""), presented_item.content[:details][:body])
  end

  test "presents an organisation with children" do
    child_organisation = create(:organisation, name: "Department for Stuff")
    organisation = create(
      :organisation,
      name: "Organisation of Things",
      child_organisations: [child_organisation],
    )

    presented_item = present(organisation)

    assert_includes presented_item.content.dig(:details, :body), "/government/organisations#organisation-of-things"
  end

  test "presents an eligible organisation with promotional features" do
    promotional_feature1 = create(:promotional_feature)
    promotional_feature_item1 = create(:promotional_feature_item, promotional_feature: promotional_feature1)
    promotional_feature2 = create(:promotional_feature)
    promotional_feature_item2 = create(:promotional_feature_item_with_youtube_video_url, promotional_feature: promotional_feature2)

    organisation = create(
      :organisation,
      organisation_type: OrganisationType.executive_office,
      promotional_features: [
        promotional_feature1,
        promotional_feature2,
      ],
    )
    presented_item = present(organisation)

    expected_output = [
      {
        title: promotional_feature1.title,
        items: [
          summary: promotional_feature_item1.summary,
          image: { url: promotional_feature_item1.image.url, alt_text: promotional_feature_item1.image_alt_text },
          links: promotional_feature_item2.links,
        ],
      },
      {
        title: promotional_feature2.title,
        items: [
          summary: promotional_feature_item2.summary,
          youtube_video: { id: promotional_feature_item2.youtube_video_id, alt_text: promotional_feature_item2.youtube_video_alt_text },
          links: promotional_feature_item2.links,
        ],
      },
    ]

    assert_equal(expected_output, presented_item.content[:details][:ordered_promotional_features])
  end

  test "filters out images with missing assets for promotional feature items" do
    promotional_feature = create(:promotional_feature)
    promotional_feature_item_with_assets = create(:promotional_feature_item, promotional_feature:)
    promotional_feature_item_with_missing_assets = build(:promotional_feature_item, promotional_feature:)
    promotional_feature_item_with_missing_assets.assets = []
    promotional_feature_item_with_missing_assets.save!

    organisation = create(
      :organisation,
      organisation_type: OrganisationType.civil_service,
      promotional_features: [promotional_feature],
    )
    presented_item = present(organisation)

    expected_output = [
      {
        title: promotional_feature.title,
        items: [
          summary: promotional_feature_item_with_assets.summary,
          image: {
            url: promotional_feature_item_with_assets.image.url,
            alt_text: promotional_feature_item_with_assets.image_alt_text,
          },
          links: promotional_feature_item_with_assets.links,
        ],
      },
    ]

    assert_equal(expected_output, presented_item.content[:details][:ordered_promotional_features])
  end

  test "does not present an ineligible organisation with promotional features" do
    promotional_feature = create(:promotional_feature)
    organisation = create(
      :organisation,
      organisation_type: OrganisationType.ministerial_department,
      promotional_features: [promotional_feature],
    )
    presented_item = present(organisation)

    assert_equal([], presented_item.content[:details][:ordered_promotional_features])
  end

  test "presents the current/new URL for a non-live organisation" do
    organisation = create(
      :organisation,
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

  test "renders courts and tribunals with 'exact' route using Collections" do
    organisation = create(
      :court,
      name: "Court at mid-wicket",
    )
    presented_item = present(organisation)

    assert_equal("collections", presented_item.content[:rendering_app])
    assert_equal([{ path: "/courts-tribunals/court-at-mid-wicket", type: "exact" }], presented_item.content[:routes])
  end

  test "presents the display type of an offsite link" do
    organisation = create(
      :court,
      name: "An organisation with offsite links",
    )
    offsite_link = create(:offsite_link, link_type: "content_publisher_news_story")
    feature = create(:feature, document: nil, offsite_link:)
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

  test "presents the correct routes for an organisation with a translation" do
    organisation = create(
      :organisation,
      translated_into: %i[en cy],
    )

    I18n.with_locale(:en) do
      presented_item = present(organisation)

      assert_equal organisation.base_path, presented_item.content[:base_path]

      assert_equal [
        { path: organisation.base_path, type: "prefix" },
        { path: "#{organisation.base_path}.atom", type: "exact" },
      ], presented_item.content[:routes]
    end

    I18n.with_locale(:cy) do
      presented_item = present(organisation)

      assert_equal "#{organisation.base_path}.cy", presented_item.content[:base_path]

      assert_equal [
        { path: "#{organisation.base_path}.cy", type: "prefix" },
        { path: "#{organisation.base_path}.cy.atom", type: "exact" },
      ], presented_item.content[:routes]
    end
  end

  test "is valid against the schema when there is no default_news_image" do
    organisation = build(:organisation, updated_at: Time.zone.now)
    organisation.default_news_image = nil

    presented_item = present(organisation)

    assert_valid_against_publisher_schema(presented_item.content, "organisation")
  end

  test "default_news_image is not present when there is no image" do
    organisation = build(:organisation, default_news_image: nil)
    presenter = PublishingApi::OrganisationPresenter.new(organisation)

    assert_not presenter.content[:details].key? :default_news_image
  end

  test "default_news_image is not present when variants are not uploaded" do
    featured_image = build(:featured_image_data)
    featured_image.assets.destroy_all
    organisation = build(:organisation, default_news_image: featured_image)
    presenter = PublishingApi::OrganisationPresenter.new(organisation)

    assert_not presenter.content[:details].key? :default_news_image
  end
end
