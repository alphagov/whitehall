require "test_helper"

class DocumentTopicTest < ActiveSupport::TestCase
  test "should be valid when built from the factory" do
    document_topic = build(:document_topic)
    assert document_topic.valid?
  end

  test "should not be valid without document" do
    document_topic = build(:document_topic, document: nil)
    refute document_topic.valid?
  end

  test "should not be valid without topic" do
    document_topic = build(:document_topic, topic: nil)
    refute document_topic.valid?
  end
end