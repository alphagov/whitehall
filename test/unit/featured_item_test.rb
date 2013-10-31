require 'test_helper'

class FeaturedItemTest < ActiveSupport::TestCase
  test 'is invalid without an item' do
    item = build(:featured_item, item: nil)
    refute item.valid?
  end

  test "is invalid without a list" do
    item = build(:featured_item, featured_topics_and_policies_list: nil)
    refute item.valid?
  end

  test 'topic_id is nil if the featured item is not a topic' do
    item = build(:featured_policy_item)
    assert item.topic_id.nil?
  end

  test 'topic_id is the id of the topic that has been featured' do
    t = create(:topic)
    item = build(:featured_topic_item, item: t)
    assert_equal t.id, item.topic_id
  end

  test 'document_id is nil if the featured item is not a document' do
    item = build(:featured_topic_item)
    assert item.document_id.nil?
  end

  test 'document_id is the id of the the document that has been featured' do
    p = create(:policy, :with_document)
    item = build(:featured_policy_item, item: p.document)
    assert_equal p.document.id, item.document_id
  end

  test "started_at set by default on creation" do
    item = FeaturedItem.create(featured_topics_and_policies_list: create(:featured_topics_and_policies_list), item: create(:topic))
    assert_equal Time.zone.now, item.started_at
  end

  test ".current lists selects features where ended_at is nil" do
    current = create(:featured_item, started_at: 2.days.ago, ended_at: nil)
    ended = create(:featured_item, started_at: 2.days.ago, ended_at: 1.day.ago)
    assert_equal [current], FeaturedItem.current
  end

  test 'linkable_item is the item when it is a topic' do
    topic = build(:topic)
    item = build(:featured_topic_item, item: topic)
    assert_equal topic, item.linkable_item
  end

  test 'linkable_item is the publised_edition of the item when it is a document' do
    p1 = create(:published_policy, :with_document)
    p2 = p1.create_draft(create(:policy_writer))
    p2.change_note = 'meh'
    force_publish(p2)

    item = build(:featured_policy_item, item: p1.document)
    assert_equal p2, item.linkable_item
  end

  test 'linkable_item is nil when the item is a document without a published edition' do
    p = create(:draft_policy, :with_document)

    item = build(:featured_policy_item, item: p.document)
    assert_nil item.linkable_item
  end

  test 'linkable_title is the title of the published edition of the item when the it is a document' do
    p1 = create(:published_policy, :with_document)
    p2 = p1.create_draft(create(:policy_writer))
    p2.change_note = 'meh'
    force_publish(p2)

    item = build(:featured_policy_item, item: p1.document)
    assert_equal p2.title, item.linkable_title
  end

  test 'linkable_title is nil when the item is a document without a published edition' do
    p = create(:draft_policy, :with_document)

    item = build(:featured_policy_item, item: p.document)
    assert_nil item.linkable_title
  end

  test 'linkable_title is the name of the item when it is a topic' do
    topic = build(:topic)
    item = build(:featured_topic_item, item: topic)
    assert_equal topic.name, item.linkable_title
  end

end
