require 'test_helper'

class PublishingApiPresenters::WorldLocationTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApiPresenters::WorldLocation.new(model_instance, options)
  end

  test 'presents a World Location ready for adding to the publishing API' do
    world_location = create(:world_location, name: 'Locationia', analytics_identifier: 'WL123')
    public_path = Whitehall.url_maker.world_location_path(world_location)

    expected_hash = {
      base_path: public_path,
      title: "Locationia",
      description: nil,
      schema_name: "placeholder",
      document_type: "world_location",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: world_location.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {},
      analytics_identifier: "WL123",
    }
    expected_links = {}

    presented_item = present(world_location)

    assert_equal expected_hash, presented_item.content
    assert_equal expected_links, presented_item.links
    assert_equal "major", presented_item.update_type
    assert_equal world_location.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end
end
