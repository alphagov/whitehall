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
          {
            content_id: worldwide_org.corporate_information_pages[3].content_id,
            title: "Read about the types of information we routinely publish in our Publication scheme.",
          },
          {
            content_id: worldwide_org.corporate_information_pages[5].content_id,
            title: "Find out about our commitment to publishing in Welsh.",
          },
          {
            content_id: worldwide_org.corporate_information_pages[2].content_id,
            title: "Our Personal information charter explains how we treat your personal information.",
          },
        ],
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
      ordered_contacts: [
        worldwide_org.reload.offices.first.contact.content_id,
      ],
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
