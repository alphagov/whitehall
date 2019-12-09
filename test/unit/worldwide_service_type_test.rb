require "test_helper"

class WorldwideServiceTypeTest < ActiveSupport::TestCase
  test "should provide slugs for every service type" do
    service_types = WorldwideServiceType.all
    assert_equal service_types.length, service_types.map(&:slug).compact.length
  end

  test "should be findable by slug" do
    service_type = WorldwideServiceType.find_by_id(1)
    assert_equal service_type, WorldwideServiceType.find_by_slug(service_type.slug)
  end
end
