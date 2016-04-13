require "test_helper"
require "gds_api/test_helpers/content_store"

class SpecialistTagFinderTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::ContentStore

  test "#topics returns all linked topics" do
    edition = create(:edition_with_document)
    edition_base_path = PublishingApiPresenters::Edition.new(edition).base_path
    content_item = content_item_for_base_path(edition_base_path).merge!({
      "links" => {
        "topics" => [
          { "title" => "topic-1" },
          { "title" => "topic-2" },
        ]
      }
    })

    content_store_has_item(edition_base_path, content_item)

    assert_equal ["topic-1", "topic-2"], SpecialistTagFinder.new(edition).topics.map { |topic| topic["title"] }
  end

  test "#grandparent_topic returns the parent of the edition's parent topic" do
    edition = create(:edition_with_document)
    edition_base_path = PublishingApiPresenters::Edition.new(edition).base_path
    parent_base_path = "/parent-item"
    edition_content_item = content_item_for_base_path(edition_base_path).merge!({
      "links" => { "parent" => [{ "base_path" => parent_base_path }] }
    })
    parent_content_item = content_item_for_base_path(parent_base_path).merge!({
      "links" => { "parent" => [{ "base_path" => "/grandpa" }] }
    })

    content_store_has_item(edition_base_path, edition_content_item)
    content_store_has_item(parent_base_path, parent_content_item)


    assert_equal "/grandpa", SpecialistTagFinder.new(edition).grandparent_topic.base_path
  end
end
