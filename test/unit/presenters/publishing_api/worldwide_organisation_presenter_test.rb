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
      rendering_app: "whitehall-frontend",
      public_updated_at: worldwide_org.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Some stuff</p>\n</div>",
        logo: {
          crest: "single-identity",
          formatted_title: "Locationia\nEmbassy",
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
      ordered_contacts: [],
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
    }

    presented_item = present(worldwide_org)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal worldwide_org.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "worldwide_organisation")
    assert_valid_against_links_schema({ links: presented_item.links }, "worldwide_organisation")
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
end
