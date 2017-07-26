require 'test_helper'

class PublishingApi::WorldLocationPresenterTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApi::WorldLocationPresenter.new(model_instance, options)
  end

  test 'presents a World Location ready for adding to the publishing API' do
    world_location = create(:world_location, name: 'Locationia', analytics_identifier: 'WL123')

    expected_hash = {
      title: "Locationia",
      description: nil,
      schema_name: "world_location",
      document_type: "world_location",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: world_location.updated_at,
      redirects: [],
      need_ids: [],
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

    assert_valid_against_schema(presented_item.content, 'world_location')
  end
end
