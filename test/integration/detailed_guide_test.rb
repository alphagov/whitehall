require 'test_helper'
require "gds_api/test_helpers/content_store"

class DetailedGuideIntegrationTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentStore

  test "meta data tag is present" do
    detailed_guide = create(:published_detailed_guide, summary: "This is a published detailed guide summary")
    stubbed_topics_finder = SpecialistTagFinder.new(detailed_guide)
    stubbed_topics_finder.stubs(top_level_topic: nil, topics: [])
    SpecialistTagFinder.stubs(:new).returns(stubbed_topics_finder)

    get detailed_guide_path(detailed_guide.slug)

    assert response.body.include? "<meta name=\"description\" content=\"This is a published detailed guide summary\" />"
  end
end
