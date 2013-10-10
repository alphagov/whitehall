require 'test_helper'

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

  test "policies can be ordered" do
    topic = create(:topic)
    first_policy = create(:published_policy, topics: [topic])
    second_policy = create(:published_policy, topics: [topic])
    first_association = topic.classification_memberships.find_by_edition_id(first_policy.id)
    second_association = topic.classification_memberships.find_by_edition_id(second_policy.id)

    topic.update_attributes(classification_memberships_attributes: {
      first_association.id => {id: first_association.id, edition_id: first_policy.id, ordering: "2"},
      second_association.id => {id: second_association.id, edition_id: second_policy.id, ordering: "1"}
    })

    assert_equal [second_policy, first_policy], topic.reload.policies
    assert_equal [second_policy, first_policy], topic.reload.published_policies
  end

  test "should be deletable if all the associated policies are archived" do
    topic = create(:topic, editions: [create(:archived_policy)])
    assert topic.destroyable?
    topic.delete!
    assert topic.deleted?
  end

  test "should not be deletable if there are non-archived associated policies" do
    topic = create(:topic, editions: [create(:policy)])
    refute topic.destroyable?
    topic.delete!
    refute topic.deleted?
  end

  test "return topics bi-directionally related to specific topic" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    topic = create(:topic, related_classifications: [topic_1, topic_2])

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
    topic = create(:topic, name: "topic name", description: "topic description")
    assert_equal({
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

    Searchable::Index.expects(:later).with(topic)

    topic.save
  end

  test 'should add topic to search index on updating' do
    topic = create(:topic)

    Searchable::Index.expects(:later).with(topic)

    topic.name = 'different topic name'
    topic.save
  end

  test 'should remove topic from search index on destroying' do
    topic = create(:topic)
    Searchable::Delete.expects(:later).with(topic)
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

  test 'should filter out topics without any published policies or documents' do
    has_nothing = create(:topic)
    create(:published_policy, topics: [has_published_policies = create(:topic)])
    create(:draft_policy, topics: [has_draft_policies = create(:topic)])
    create(:draft_detailed_guide, topics: [has_draft_detailed_guides = create(:topic)])
    create(:published_detailed_guide, topics: [has_published_detailed_guides = create(:topic)])

    topics = Topic.with_content.all

    assert_includes topics, has_published_policies
    assert_includes topics, has_published_detailed_guides
    refute_includes topics, has_draft_policies
    refute_includes topics, has_draft_detailed_guides
    refute_includes topics, has_nothing
  end

  test 'should be retrievable in an alphabetically ordered list' do
    cheese = create(:topic, name: "Cheese")
    bananas = create(:topic, name: "Bananas")
    dates = create(:topic, name: "Dates")
    apples = create(:topic, name: "Apples")

    assert_equal [apples, bananas, cheese, dates], Topic.alphabetical
  end

  test "should update count of published editions" do
    topic = create(:topic)
    assert_equal 0, topic.published_edition_count

    policy = create(:published_policy)
    classification_membership = create(:classification_membership, classification: topic, policy: policy)
    assert_equal 1, topic.reload.published_edition_count

    policy.update_attributes(state: :draft)
    assert_equal 0, topic.reload.published_edition_count

    policy.update_attributes(state: :published)
    assert_equal 1, topic.reload.published_edition_count

    classification_membership.reload.destroy
    assert_equal 0, topic.reload.published_edition_count
  end

  test "should update count of published policies" do
    topic = create(:topic)
    assert_equal 0, topic.published_policies_count

    policy = create(:published_policy)
    classification_membership = create(:classification_membership, classification: topic, policy: policy)
    assert_equal 1, topic.reload.published_policies_count

    policy.update_attributes(state: :draft)
    assert_equal 0, topic.reload.published_policies_count

    policy.update_attributes(state: :published)
    assert_equal 1, topic.reload.published_policies_count

    classification_membership.reload.destroy
    assert_equal 0, topic.reload.published_policies_count
  end


  ### Describing top tasks ###

  test 'should be creatable with top task data' do
    params = {
      top_tasks_attributes: [
        {url: "https://www.gov.uk/blah/blah",
         title: "Blah blah"},
        {url: "https://www.gov.uk/wah/wah",
         title: "Wah wah"},
      ]
    }
    topic = create(:topic, params)

    links = topic.top_tasks
    assert_equal 2, links.count
    assert_equal "https://www.gov.uk/blah/blah", links[0].url
    assert_equal "Blah blah", links[0].title
    assert_equal "https://www.gov.uk/wah/wah", links[1].url
    assert_equal "Wah wah", links[1].title
  end

  test 'top tasks are returned in order of creation' do
    topic = create(:topic)
    link_1 = create(:top_task, linkable: topic, title: '2 days ago', created_at: 2.days.ago)
    link_2 = create(:top_task, linkable: topic, title: '12 days ago', created_at: 12.days.ago)
    link_3 = create(:top_task, linkable: topic, title: '1 hour ago', created_at: 1.hour.ago)
    link_4 = create(:top_task, linkable: topic, title: '2 hours ago', created_at: 2.hours.ago)
    link_5 = create(:top_task, linkable: topic, title: '20 minutes ago', created_at: 20.minutes.ago)
    link_6 = create(:top_task, linkable: topic, title: '2 years ago', created_at: 2.years.ago)

    assert_equal [link_6, link_2, link_1, link_4, link_3, link_5], topic.top_tasks
  end

  test 'should ignore blank top task attributes' do
    params = {
      top_tasks_attributes: [
        {url: "",
         title: ""}
      ]
    }
    topic = build(:topic, params)
    assert topic.top_tasks.empty?
  end
end
