require "test_helper"

class SpecialistTopicFetcherTest < ActiveSupport::TestCase
  include SpecialistTopicHelper

  test "#permitted_specialist_topic returns a content item for level two curated topics" do
    stub_valid_specialist_topic
    assert_equal SpecialistTopicFetcher.call(specialist_topic_base_path), specialist_topic_content_item
  end

  test "#permitted_specialist_topic raises an error for level one topics" do
    stub_level_one_specialist_topic

    exception = assert_raises(Exception) { SpecialistTopicFetcher.call(specialist_topic_base_path) }
    assert_equal("Not a level two topic", exception.message)
  end

  test "#permitted_specialist_topic raises an error for uncurated topics" do
    stub_uncurated_specialist_topic

    exception = assert_raises(Exception) { SpecialistTopicFetcher.call(specialist_topic_base_path) }
    assert_equal("Not a curated topic", exception.message)
  end

  test "#permitted_specialist_topic raises an error if no topic exists" do
    stub_publishing_api_has_lookups(specialist_topic_base_path => nil)

    exception = assert_raises(Exception) { SpecialistTopicFetcher.call(specialist_topic_base_path) }
    assert_equal("No specialist topic with that base path", exception.message)
  end
end
