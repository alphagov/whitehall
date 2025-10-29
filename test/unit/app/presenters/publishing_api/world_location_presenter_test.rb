require "test_helper"

class PublishingApi::WorldLocationPresenterTest < ActiveSupport::TestCase
  def present(...)
    PublishingApi::WorldLocationPresenter.new(...)
  end

  test "presents a World Location ready for adding to the publishing API" do
    world_location = create(:world_location, name: "Locationia", analytics_identifier: "WL123")

    expected_hash = {
      title: "Locationia",
      description: nil,
      schema_name: "world_location",
      document_type: "world_location",
      locale: "en",
      publishing_app: Whitehall::PublishingApp::WHITEHALL,
      public_updated_at: world_location.updated_at,
      redirects: [],
      details: {},
      analytics_identifier: "WL123",
      update_type: "major",
      base_path: nil,
      rendering_app: nil,
    }
    expected_links = {
      world_location_news: [world_location.world_location_news.content_id],
    }

    presented_item = present(world_location)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal world_location.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "world_location")
    assert_valid_against_links_schema({ links: presented_item.links }, "world_location")
  end
end
