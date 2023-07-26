require "test_helper"

class PublishingApi::WorldIndexPresenterTest < ActiveSupport::TestCase
  setup do
    @world_location_2 = create(
      :world_location,
      name: "Location 2",
      slug: "location-2",
      active: false,
      analytics_identifier: "B2",
      iso2: "CD",
    )
    @world_location_1 = create(
      :world_location,
      name: "Location 1",
      slug: "location-1",
      active: true,
      analytics_identifier: "A1",
      iso2: "AB",
    )
    @international_delegation = create(
      :international_delegation,
      name: "Delegation",
      slug: "delegation",
      active: true,
      analytics_identifier: "C3",
      iso2: nil,
    )
  end

  test "presents a valid content item with locations sorted into the correct order" do
    expected_hash = {
      base_path: "/world",
      details: {
        world_locations: [
          {
            active: true,
            analytics_identifier: "A1",
            content_id: @world_location_1.content_id,
            iso2: "AB",
            name: "Location 1",
            slug: "location-1",
            updated_at: @world_location_1.updated_at,
          },
          {
            active: false,
            analytics_identifier: "B2",
            content_id: @world_location_2.content_id,
            iso2: "CD",
            name: "Location 2",
            slug: "location-2",
            updated_at: @world_location_2.updated_at,
          },
        ],
        international_delegations: [
          {
            active: true,
            analytics_identifier: "C3",
            content_id: @international_delegation.content_id,
            iso2: nil,
            name: "Delegation",
            slug: "delegation",
            updated_at: @international_delegation.updated_at,
          },
        ],
      },
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
      schema_name: "world_index",
      document_type: "world_index",
      title: "Help and services around the world",
      locale: "en",
      routes: [
        {
          path: "/world",
          type: "exact",
        },
      ],
      update_type: "major",
      redirects: [],
      public_updated_at: Time.zone.now,
    }

    expected_links = {}

    presenter = PublishingApi::WorldIndexPresenter.new

    assert_equal expected_hash, presenter.content
    assert_valid_against_publisher_schema(presenter.content, "world_index")

    assert_equal expected_links, presenter.links
    assert_valid_against_links_schema({ links: presenter.links }, "world_index")
  end
end
