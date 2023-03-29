require "test_helper"

class PublishingApi::WorldIndexPresenterTest < ActiveSupport::TestCase
  setup do
    @world_location_1 = create(:world_location, name: "Location 1", slug: "location-1", active: true)
    @world_location_2 = create(:world_location, name: "Location 2", slug: "location-2", active: false)
    @international_delegation = create(:international_delegation, name: "Delegation", slug: "delegation", active: true)
  end

  test "presents a valid content item" do
    expected_hash = {
      base_path: "/world",
      details: {
        world_locations: [
          {
            name: "Location 1",
            slug: "location-1",
            active: true,
          },
          {
            name: "Location 2",
            slug: "location-2",
            active: false,
          },
        ],
        international_delegations: [
          {
            name: "Delegation",
            slug: "delegation",
            active: true,
          },
        ],
      },
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
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
