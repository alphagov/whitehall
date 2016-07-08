require "test_helper"

class TagDetailsSerializerTest < ActiveSupport::TestCase
  def stubbed_item
    stub(
      can_be_related_to_policies?: true,
      policies: [stub(slug: 'slug_1'), stub(slug: 'slug_2')],
      primary_specialist_sector_tag: 'primary_topic',
      secondary_specialist_sector_tags: %w(secondary_topic_1 secondary_topic_2)
    )
  end

  def serializer
    TagDetailsSerializer.new(stubbed_item)
  end

  test "it includes browse pages" do
    assert_equal serializer.browse_pages, []
  end

  test "it includes policies when the item can be related to policies" do
    assert_equal serializer.policies, %w(slug_1 slug_2)
  end

  test "it includes no policies when the item cannot be related to policies" do
    stubbed_item = stub(
      can_be_related_to_policies?: false
    )
    serializer = TagDetailsSerializer.new(stubbed_item)
    assert_equal serializer.policies, []
  end

  test "it includes both the primary and secondary topics" do
    assert_equal(
      serializer.topics,
      %w(primary_topic secondary_topic_1 secondary_topic_2)
    )
  end
end
