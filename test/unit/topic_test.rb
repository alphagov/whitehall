require 'test_helper'

# NB: Topic is being renamed to "Policy Area" across GOV.UK.
class TopicTest < ActiveSupport::TestCase
  test "should set a slug from the topic name" do
    topic = create(:topic, name: 'Love all the people')
    assert_equal 'love-all-the-people', topic.slug
  end

  test "should not change the slug when the name is changed" do
    topic = create(:topic, name: 'Love all the people')
    topic.update_attributes(name: 'Hold hands')
    assert_equal 'love-all-the-people', topic.slug
  end

  test "should not include apostrophes in slug" do
    topic = create(:topic, name: "Bob's bike")
    assert_equal 'bobs-bike', topic.slug
  end

  test "should not be deletable if there are associated policies" do
    topic = create(:topic, policy_content_ids: [])
    assert topic.destroyable?

    topic.update(policy_content_ids: [policy_1["content_id"]])

    refute topic.destroyable?
    topic.delete!
    refute topic.deleted?
  end

  test 'includes linked policies with multiple parents' do
    topic = create(:topic)
    assert_equal [], topic.policy_content_ids

    topic.policy_content_ids = [policy_2.fetch("content_id")]
    assert_equal [
      policy_area_1.fetch("content_id"),
      policy_area_2.fetch("content_id"),
      policy_2.fetch("content_id"),
    ], topic.policy_content_ids
  end

  test "return topics bi-directionally related to specific topic" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    topic = build(:topic, related_classifications: [topic_1, topic_2])
    topic.save!

    assert_equal [topic_1, topic_2], topic.related_classifications
    assert_equal [topic], topic_1.related_classifications
    assert_equal [topic], topic_2.related_classifications
  end

  test "should add related topics bi-directionally" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    topic = create(:topic, related_classifications: [])

    topic.update_attributes!(related_classification_ids: [topic_1.id, topic_2.id])

    assert_equal [topic_1, topic_2], topic.related_classifications
    assert_equal [topic], topic_1.related_classifications
    assert_equal [topic], topic_2.related_classifications
  end

  test "should remove related topics bi-directionally" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    topic = create(:topic, related_classifications: [topic_1, topic_2])

    topic.update_attributes!(related_classification_ids: [])

    assert_equal [], topic.related_classifications
    assert_equal [], topic_1.related_classifications
    assert_equal [], topic_2.related_classifications
  end

  test 'should return search index data suitable for Rummageable' do
    topic = create(:topic, content_id: 'aa1f1646-6ae6-4a65-86e3-9803fa870c6a', name: "topic name", description: "topic description")
    assert_equal({
                  'content_id' => 'aa1f1646-6ae6-4a65-86e3-9803fa870c6a',
                  'title' => 'topic name',
                  'link' => '/government/topics/topic-name',
                  'indexable_content' => 'topic description',
                  'format' => 'topic',
                  'description' => 'topic description',
                  'slug' => 'topic-name'
                  },
                topic.search_index)
  end

  test 'should add topic to search index on creating' do
    topic = build(:topic)

    Whitehall::SearchIndex.expects(:add).with(topic)

    topic.save
  end

  test 'should add topic to search index on updating' do
    topic = create(:topic)

    Whitehall::SearchIndex.expects(:add).with(topic)

    topic.name = 'different topic name'
    topic.save
  end

  test 'should remove topic from search index on destroying' do
    topic = create(:topic)
    Whitehall::SearchIndex.expects(:delete).with(topic)
    topic.destroy
  end

  test 'should return search index data for all topics' do
    create(:topic)
    create(:topic)
    create(:topic)
    create(:topic)

    results = Topic.search_index.to_a

    assert_equal 4, results.length
  end

  test 'should be retrievable in an alphabetically ordered list' do
    cheese = create(:topic, name: "Cheese")
    bananas = create(:topic, name: "Bananas")
    dates = create(:topic, name: "Dates")
    apples = create(:topic, name: "Apples")

    assert_equal [apples, bananas, cheese, dates], Topic.alphabetical
  end

  ### Describing top tasks ###

  test 'should be creatable with featured link data' do
    params = {
      featured_links_attributes: [
        { url: "https://www.gov.uk/blah/blah",
         title: "Blah blah" },
        { url: "https://www.gov.uk/wah/wah",
         title: "Wah wah" },
      ]
    }
    topic = create(:topic, params)

    links = topic.featured_links
    assert_equal 2, links.count
    assert_equal "https://www.gov.uk/blah/blah", links[0].url
    assert_equal "Blah blah", links[0].title
    assert_equal "https://www.gov.uk/wah/wah", links[1].url
    assert_equal "Wah wah", links[1].title
  end

  test 'feature links are returned in order of creation' do
    topic = create(:topic)
    link_1 = create(:featured_link, linkable: topic, title: '2 days ago', created_at: 2.days.ago)
    link_2 = create(:featured_link, linkable: topic, title: '12 days ago', created_at: 12.days.ago)
    link_3 = create(:featured_link, linkable: topic, title: '1 hour ago', created_at: 1.hour.ago)
    link_4 = create(:featured_link, linkable: topic, title: '2 hours ago', created_at: 2.hours.ago)
    link_5 = create(:featured_link, linkable: topic, title: '20 minutes ago', created_at: 20.minutes.ago)
    link_6 = create(:featured_link, linkable: topic, title: '2 years ago', created_at: 2.years.ago)

    assert_equal [link_6, link_2, link_1, link_4, link_3, link_5], topic.featured_links
  end

  test 'should ignore blank featured link attributes' do
    params = {
      featured_links_attributes: [
        { url: "",
         title: "" }
      ]
    }
    topic = build(:topic, params)
    assert topic.featured_links.empty?
  end

  test "with_statistics_announcements scopes to organisations with associated statistics_announcements" do
    topic_with_announcement = create(:topic)
    create(:statistics_announcement, topics: [topic_with_announcement])
    _topic_without_announcement = create(:topic)
    assert_equal [topic_with_announcement], Topic.with_statistics_announcements
  end
end
