require 'test_helper'

class DetailedGuideIntegrationTest < ActionDispatch::IntegrationTest
  test "meta data tag is present" do
    detailed_guide = create(:published_detailed_guide, summary: "This is a published detailed guide summary")

    get detailed_guide_path(detailed_guide.slug)

    assert response.body.include? "<meta name=\"description\" content=\"This is a published detailed guide summary\" />"
  end
end
