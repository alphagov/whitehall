require "test_helper"
require "specialist_topic_migration/specialist_topic"

class SpecialistTopicMigration::SpecialistTopicTest < ActiveSupport::TestCase
  setup do
    @groups = [
      {
        "name" => "How to claim",
        "contents" => [
          "/child-benefit",
          "/child-benefit-number",
          "/claim-child-benefit-behalf-someone-else",
          "/guardians-allowance",
        ],
      },
    ]
    stub_publishing_api_has_lookups("/specialist-topic-one" => "123")
    stub_publishing_api_has_item(
      "content_id" => "123",
      "title" => "specialist topic one",
      "base_path" => "/specialist-topic-one",
      "description" => "This is a specialist topic",
      "details" => {
        "groups" => @groups,
      },
    )
  end

  test "should build a specialist topic" do
    topic = SpecialistTopicMigration::SpecialistTopic.find!("/specialist-topic-one")
    assert_equal "/specialist-topic-one", topic.base_path
    assert_equal "123", topic.content_id
    assert_equal "This is a specialist topic", topic.description
    assert_equal @groups, topic.groups
  end
end
