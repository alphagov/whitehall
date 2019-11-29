require "test_helper"

class WorldLocationTypeTest < ActiveSupport::TestCase
  test "should provide slugs for every world location type" do
    world_location_types = WorldLocationType.all
    assert_equal world_location_types.length, world_location_types.map(&:slug).compact.length
  end

  test "should be findable by slug" do
    world_location_type = WorldLocationType.find_by(id: 1)
    assert_equal world_location_type, WorldLocationType.find_by(slug: world_location_type.slug)
  end

  test "we can find those types that are geographic" do
    assert_equal [WorldLocationType::WorldLocation], WorldLocationType.geographic
  end
end
