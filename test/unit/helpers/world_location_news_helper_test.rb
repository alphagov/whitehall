require 'test_helper'

class WorldLocationNewsHelperTest < ActiveSupport::TestCase
  include WorldLocationNewsHelper

  test "world_location_news_path uses English slug not native name" do
    # Test the Turkey example from the ticket: native name "Türkiye" vs English slug "turkey"
    turkey = create(:world_location, name: "Türkiye", slug: "turkey")
    
    result = world_location_news_path(turkey)
    
    assert_equal "/world/turkey/news", result
    refute_includes result, "Türkiye", "Should not use native name in URL"
  end

  test "world_location_news_path handles international delegations without /news suffix" do
    delegation = create(:international_delegation, slug: "eu-delegation")
    
    result = world_location_news_path(delegation)
    
    assert_equal "/world/eu-delegation", result
  end
end
