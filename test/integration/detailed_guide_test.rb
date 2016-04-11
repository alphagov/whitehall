require 'test_helper'
require "gds_api/test_helpers/content_store"

class DetailedGuideIntegrationTest < ActionDispatch::IntegrationTest
  include GdsApi::TestHelpers::ContentStore

  test "meta data tag is present" do
    detailed_guide = create(:published_detailed_guide, summary: "This is a published detailed guide summary")
    stubbed_topics_finder = SpecialistTagFinder.new(detailed_guide)
    stubbed_topics_finder.stubs(grandparent_topic: nil, topics: [])
    SpecialistTagFinder.stubs(:new).returns(stubbed_topics_finder)

    get detailed_guide_path(detailed_guide.slug)

    assert response.body.include? "<meta name=\"description\" content=\"This is a published detailed guide summary\" />"
  end

  test "the page header is rendered with correct topic tags" do
    detailed_guide = create(:published_detailed_guide)
    detailed_guide_base_path = PublishingApiPresenters.presenter_for(detailed_guide).base_path
    parent_base_path = "/parent-item"
    detailed_guide_content_item = content_item_for_base_path(detailed_guide_base_path).merge!({
      "links" => { "parent" => [{ "base_path" => parent_base_path }] }
    })
    parent_content_item = content_item_for_base_path(parent_base_path).merge!({
      "links" => { "parent" => [{ "title" => "Grandpa", "web_url" => "http://grandpa.com" }] }
    })
    content_store_has_item(detailed_guide_base_path, detailed_guide_content_item)
    content_store_has_item(parent_base_path, parent_content_item)

    get detailed_guide_path(detailed_guide.slug)

    assert response.body.include? '<p class="type"><a href="http://grandpa.com">Grandpa</a> &ndash; guidance</p>'
  end
end
