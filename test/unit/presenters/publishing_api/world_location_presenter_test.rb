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
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      public_updated_at: world_location.updated_at,
      redirects: [],
      details: {},
      analytics_identifier: "WL123",
      update_type: "major",
    }
    expected_links = {}

    presented_item = present(world_location)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal world_location.content_id, presented_item.content_id

    assert_valid_against_publisher_schema(presented_item.content, "world_location")
  end

  test "presents the correct routes for an international delegation with a translation" do
    world_location = create(:international_delegation,
                            name: "UK Delegation to Narnia",
                            translated_into: [:cy])

    expected_base_path = "/world/uk-delegation-to-narnia"

    I18n.with_locale(:en) do
      presented_item = present(world_location)

      assert_equal expected_base_path, presented_item.content[:base_path]

      assert_equal [
        { path: expected_base_path, type: "exact" },
      ], presented_item.content[:routes]
    end

    I18n.with_locale(:cy) do
      presented_item = present(world_location)

      assert_equal "#{expected_base_path}.cy", presented_item.content[:base_path]

      assert_equal [
        { path: "#{expected_base_path}.cy", type: "exact" },
      ], presented_item.content[:routes]
    end
  end
end
