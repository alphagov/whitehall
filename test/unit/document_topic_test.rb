require "test_helper"

class DocumentTopicTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    document_topic = build(:document_topic)
    assert document_topic.valid?
  end
end