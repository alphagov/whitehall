require "test_helper"

class PublishingApi::EditionableWorldwideOrganisationPresenterTest < ActiveSupport::TestCase
  def present(...)
    PublishingApi::EditionableWorldwideOrganisationPresenter.new(...)
  end

  test "presents a Worldwide Organisation ready for adding to the publishing API" do
    worldwide_org = create(:editionable_worldwide_organisation,
                           :with_role,
                           :with_social_media_account)

    primary_role = create(:ambassador_role)
    ambassador = create(:person)
    create(:ambassador_role_appointment, role: primary_role, person: ambassador)
    worldwide_org.roles << primary_role

    secondary_role = create(:deputy_head_of_mission_role)
    deputy_head_of_mission = create(:person)
    create(:deputy_head_of_mission_role_appointment, role: secondary_role, person: deputy_head_of_mission)
    worldwide_org.roles << secondary_role

    public_path = worldwide_org.public_path

    expected_hash = {
      base_path: public_path,
      title: worldwide_org.title,
      schema_name: "worldwide_organisation",
      document_type: "worldwide_organisation",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: Whitehall::RenderingApp::GOVERNMENT_FRONTEND,
      public_updated_at: worldwide_org.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      details: {
        body: "<div class=\"govspeak\"><p>Information about the organisation with <em>italics</em>.</p>\n</div>",
        logo: {
          crest: "single-identity",
          formatted_title: "Editionable<br/>worldwide<br/>organisation<br/>title",
        },
        social_media_links: [
          {
            href: worldwide_org.social_media_accounts.first.url,
            service_type: worldwide_org.social_media_accounts.first.service_name.parameterize,
            title: worldwide_org.social_media_accounts.first.display_name,
          },
        ],
        world_location_names: [
          {
            content_id: worldwide_org.world_locations.first.content_id,
            name: worldwide_org.world_locations.first.name,
          },
        ],
      },
      update_type: "major",
    }

    expected_links = {
      office_staff: worldwide_org.office_staff_roles.map(&:current_person).map(&:content_id),
      primary_role_person: [
        ambassador.content_id,
      ],
      roles: worldwide_org.roles.map(&:content_id),
      secondary_role_person: [
        deputy_head_of_mission.content_id,
      ],
      sponsoring_organisations: worldwide_org.organisations.map(&:content_id),
      world_locations: worldwide_org.world_locations.map(&:content_id),
    }

    presented_item = present(worldwide_org)

    assert_equal expected_hash, presented_item.content
    assert_equal "major", presented_item.update_type
    assert_equal worldwide_org.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "worldwide_organisation")

    assert_equal expected_links, presented_item.links
    assert_valid_against_links_schema({ links: presented_item.links }, "worldwide_organisation")
  end

  test "uses the title for the formatted_title when the locale is not en" do
    I18n.with_locale(:it) do
      worldwide_org = create(:editionable_worldwide_organisation, title: "Consolato Generale Britannico Milano")

      presented_item = present(worldwide_org)

      assert_equal "Consolato Generale Britannico Milano", presented_item.content.dig(:details, :logo, :formatted_title)
    end
  end

  test "uses the title for the formatted_title when the the logo_formatted_name is absent" do
    worldwide_org = create(:editionable_worldwide_organisation, logo_formatted_name: nil)

    presented_item = present(worldwide_org)

    assert_equal "Editionable worldwide organisation title", presented_item.content.dig(:details, :logo, :formatted_title)
  end
end
