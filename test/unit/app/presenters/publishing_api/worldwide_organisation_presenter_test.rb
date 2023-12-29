require "test_helper"

class PublishingApi::WorldwideOrganisationPresenterTest < ActiveSupport::TestCase
  def present(...)
    PublishingApi::WorldwideOrganisationPresenter.new(...)
  end

  test "presents a Worldwide Organisation ready for adding to the publishing API" do
    worldwide_org = create(:worldwide_organisation,
                           :with_corporate_information_pages,
                           :with_office,
                           :with_social_media_accounts,
                           :with_sponsorships,
                           :with_world_location,
                           name: "Locationia Embassy",
                           analytics_identifier: "WO123")

    primary_role = create(:ambassador_role)
    ambassador = create(:person)
    create(:ambassador_role_appointment, role: primary_role, person: ambassador)
    FactoryBot.create(:worldwide_organisation_role, worldwide_organisation: worldwide_org, role: primary_role)

    secondary_role = create(:deputy_head_of_mission_role)
    deputy_head_of_mission = create(:person)
    create(:deputy_head_of_mission_role_appointment, role: secondary_role, person: deputy_head_of_mission)
    FactoryBot.create(:worldwide_organisation_role, worldwide_organisation: worldwide_org, role: secondary_role)

    public_path = worldwide_org.public_path

    expected_hash = {
      base_path: public_path,
      title: "Locationia Embassy",
      description: "edition-summary",
      schema_name: "worldwide_organisation",
      document_type: "worldwide_organisation",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
      public_updated_at: worldwide_org.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Some stuff</p>\n</div>",
        logo: {
          crest: "single-identity",
          formatted_title: "Locationia<br/>Embassy",
        },
        ordered_corporate_information_pages: [
          {
            content_id: worldwide_org.corporate_information_pages[1].content_id,
            title: "Complaints procedure",
          },
          {
            content_id: worldwide_org.corporate_information_pages[4].content_id,
            title: "Working for Locationia Embassy",
          },
        ],
        secondary_corporate_information_pages: "Read about the types of information we routinely publish in our <a class=\"govuk-link\" href=\"/world/organisations/locationia-embassy/about/publication-scheme\">Publication scheme</a>. Find out about our commitment to <a class=\"govuk-link\" href=\"/world/organisations/locationia-embassy/about/welsh-language-scheme\">publishing in Welsh</a>. Our <a class=\"govuk-link\" href=\"/world/organisations/locationia-embassy/about/personal-information-charter\">Personal information charter</a> explains how we treat your personal information.",
        social_media_links: [
          {
            href: "https://www.facebook.com/UKgovernment",
            service_type: "facebook",
            title: "Our Facebook Page",
          },
        ],
        world_location_names: [
          {
            content_id: worldwide_org.world_locations.first.content_id,
            name: worldwide_org.world_locations.first.name,
          },
        ],
      },
      analytics_identifier: "WO123",
      update_type: "major",
    }

    expected_links = {
      corporate_information_pages: [
        worldwide_org.corporate_information_pages[0].content_id,
        worldwide_org.corporate_information_pages[1].content_id,
        worldwide_org.corporate_information_pages[2].content_id,
        worldwide_org.corporate_information_pages[3].content_id,
        worldwide_org.corporate_information_pages[4].content_id,
        worldwide_org.corporate_information_pages[5].content_id,
      ],
      main_office: [
        worldwide_org.reload.offices.first.content_id,
      ],
      home_page_offices: [],
      primary_role_person: [
        ambassador.content_id,
      ],
      secondary_role_person: [
        deputy_head_of_mission.content_id,
      ],
      office_staff: worldwide_org.reload.office_staff_roles.map(&:current_person).map(&:content_id),
      sponsoring_organisations: [
        worldwide_org.sponsoring_organisations.first.content_id,
      ],
      world_locations: [
        worldwide_org.world_locations.first.content_id,
      ],
      roles: [
        ambassador.roles.first.content_id, deputy_head_of_mission.roles.first.content_id
      ],
    }

    presented_item = present(worldwide_org)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal worldwide_org.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "worldwide_organisation")
    assert_valid_against_links_schema({ links: presented_item.links }, "worldwide_organisation")
  end

  test "the body of a worldwide org includes linked attachments if the About us page has linked attachments" do
    worldwide_org = create(:worldwide_organisation)
    create(:about_corporate_information_page,
           organisation: nil,
           body: "Some stuff and some attachments\n[AttachmentLink: greenpaper.pdf]",
           worldwide_organisation: worldwide_org,
           attachments: [create(:file_attachment)])
    expected_body_text = "<div class=\"govspeak\"><p>Some stuff and some attachments"
    expected_body_attachment_link = Regexp.new(/<a class="govuk-link" href="#{Plek.asset_root}\/media\/\w+\/greenpaper.pdf">file-attachment-title-\d+<\/a>/)
    expected_body_attachment_metadata = "(<span class=\"gem-c-attachment-link__attribute\"><abbr title=\"Portable Document Format\" class=\"gem-c-attachment-link__abbr\">PDF</abbr></span>, <span class=\"gem-c-attachment-link__attribute\">3.39 KB</span>, <span class=\"gem-c-attachment-link__attribute\">1 page</span>)"

    presented_item = present(worldwide_org)
    assert_match expected_body_text, presented_item.body
    assert_match expected_body_attachment_link, presented_item.body
    assert_match expected_body_attachment_metadata, presented_item.body
  end

  test "presents the correct routes for a worldwide organisation with a translation" do
    worldwide_organisation = create(
      :worldwide_organisation,
      translated_into: %i[en cy],
    )

    I18n.with_locale(:en) do
      presented_item = present(worldwide_organisation)

      assert_equal worldwide_organisation.base_path, presented_item.content[:base_path]

      assert_equal [
        { path: worldwide_organisation.base_path, type: "exact" },
      ], presented_item.content[:routes]
    end

    I18n.with_locale(:cy) do
      presented_item = present(worldwide_organisation)

      assert_equal "#{worldwide_organisation.base_path}.cy", presented_item.content[:base_path]

      assert_equal [
        { path: "#{worldwide_organisation.base_path}.cy", type: "exact" },
      ], presented_item.content[:routes]
    end
  end

  test "uses the title for the formatted_title when the locale is not en" do
    I18n.with_locale(:ar) do
      worldwide_org = create(:worldwide_organisation, name: "Consolato Generale Britannico Milano")

      presented_item = present(worldwide_org)

      assert_equal "Consolato Generale Britannico Milano", presented_item.content.dig(:details, :logo, :formatted_title)
    end
  end

  test "uses the title for the formatted_title when the the logo_formatted_name is absent" do
    worldwide_org = create(:worldwide_organisation)

    presented_item = present(worldwide_org)

    assert_equal worldwide_org.name, presented_item.content.dig(:details, :logo, :formatted_title)
  end
end
