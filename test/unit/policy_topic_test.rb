require 'test_helper'

class PolicyTopicTest < ActiveSupport::TestCase
  test "should default to the 'current' state" do
    policy_topic = PolicyTopic.new
    assert policy_topic.current?
  end

  test 'should be invalid without a name' do
    policy_topic = build(:policy_topic, name: nil)
    refute policy_topic.valid?
  end

  test "should be invalid without a state" do
    policy_topic = build(:policy_topic, state: nil)
    refute policy_topic.valid?
  end

  test "should be invalid with an unsupported state" do
    policy_topic = build(:policy_topic, state: "foobar")
    refute policy_topic.valid?
  end

  test 'should be invalid without a unique name' do
    existing_policy_topic = create(:policy_topic)
    new_policy_topic = build(:policy_topic, name: existing_policy_topic.name)
    refute new_policy_topic.valid?
  end

  test 'should be invalid without a description' do
    policy_topic = build(:policy_topic, description: nil)
    refute policy_topic.valid?
  end

  test "should return a list of policy topics with published policies" do
    policy_topic_with_published_policy = create(:policy_topic, policies: [build(:published_policy)])
    create(:policy_topic, policies: [build(:draft_policy)])

    expected = [policy_topic_with_published_policy]
    assert_equal expected, PolicyTopic.with_published_policies
  end

  test "should set a slug from the policy topic name" do
    policy_topic = create(:policy_topic, name: 'Love all the people')
    assert_equal 'love-all-the-people', policy_topic.slug
  end

  test "should not change the slug when the name is changed" do
    policy_topic = create(:policy_topic, name: 'Love all the people')
    policy_topic.update_attributes(name: 'Hold hands')
    assert_equal 'love-all-the-people', policy_topic.slug
  end

  test "should concatenate words containing apostrophes" do
    policy_topic = create(:policy_topic, name: "Bob's bike")
    assert_equal 'bobs-bike', policy_topic.slug
  end

  test "should allow setting ordering of policies" do
    policy_topic = create(:policy_topic)
    first_policy = create(:policy, policy_topics: [policy_topic])
    second_policy = create(:policy, policy_topics: [policy_topic])
    first_association = policy_topic.policy_topic_memberships.find_by_policy_id(first_policy.id)
    second_association = policy_topic.policy_topic_memberships.find_by_policy_id(second_policy.id)

    policy_topic.update_attributes(policy_topic_memberships_attributes: {
      first_association.id => {id: first_association.id, policy_id: first_policy.id, ordering: "2"},
      second_association.id => {id: second_association.id, policy_id: second_policy.id, ordering: "1"}
    })

    assert_equal 2, first_association.reload.ordering
    assert_equal 1, second_association.reload.ordering
  end

  test ".featured includes all featured policy topics" do
    policy_topic = create(:policy_topic, featured: true)
    assert PolicyTopic.featured.include?(policy_topic)
  end

  test ".featured excludes unfeatured policy topics" do
    policy_topic = create(:policy_topic, featured: false)
    refute PolicyTopic.featured.include?(policy_topic)
  end

  test "return published editions relating to policies in the policy topic" do
    policy = create(:published_policy)
    publication_1 = create(:published_publication, related_policies: [policy])
    policy_topic = create(:policy_topic, policies: [policy])

    assert_equal [publication_1], policy_topic.published_related_editions
  end

  test "return published editions relating to policies in the policy topic without duplicates" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    publication_1 = create(:published_publication, related_policies: [policy_1])
    publication_2 = create(:published_publication, related_policies: [policy_1, policy_2])
    policy_topic = create(:policy_topic, policies: [policy_1, policy_2])

    assert_equal [publication_1, publication_2], policy_topic.published_related_editions
  end

  test "return only *published* editions relating to policies in the policy topic" do
    published_policy = create(:published_policy)
    create(:draft_publication, related_policies: [published_policy])
    policy_topic = create(:policy_topic, policies: [published_policy])

    assert_equal [], policy_topic.published_related_editions
  end

  test "return editions relating to only *published* policies in the policy topic" do
    draft_policy = create(:draft_policy)
    create(:published_publication, related_policies: [draft_policy])
    policy_topic = create(:policy_topic, policies: [draft_policy])

    assert_equal [], policy_topic.published_related_editions
  end

  test "return published editions relating from policies in the policy topic without duplicates" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    publication_1 = create(:published_publication, related_policies: [policy_1, policy_2])
    publication_2 = create(:published_publication, related_policies: [policy_1])
    policy_topic = create(:policy_topic, policies: [policy_1, policy_2])

    assert_equal [publication_1, publication_2], policy_topic.published_related_editions
  end

  test "return only *published* editions relating from policies in the policy topic" do
    published_policy = create(:published_policy)
    draft_publication = create(:draft_publication, related_policies: [published_policy])
    policy_topic = create(:policy_topic, policies: [published_policy])

    assert_equal [], policy_topic.published_related_editions
  end

  test "return editions relating from only *published* policies in the policy topic" do
    draft_policy = create(:draft_policy)
    published_publication = create(:published_publication, related_policies: [draft_policy])
    policy_topic = create(:policy_topic, policies: [draft_policy])

    assert_equal [], policy_topic.published_related_editions
  end

  test "should exclude deleted policy topics by default" do
    current_policy_topic = create(:policy_topic)
    deleted_policy_topic = create(:policy_topic, state: "deleted")
    assert_equal [current_policy_topic], PolicyTopic.all
  end

  test "should be deletable when there are no associated editions" do
    policy_topic = create(:policy_topic)
    assert policy_topic.destroyable?
    policy_topic.delete!
    assert policy_topic.deleted?
  end

  test "should be deletable if all the associated policies are archived" do
    policy_topic = create(:policy_topic, policies: [create(:archived_policy)])
    assert policy_topic.destroyable?
    policy_topic.delete!
    assert policy_topic.deleted?
  end

  test "should not be deletable if there are non-archived associated policies" do
    policy_topic = create(:policy_topic, policies: [create(:policy)])
    refute policy_topic.destroyable?
    policy_topic.delete!
    refute policy_topic.deleted?
  end

  test "should return the list of archived policies" do
    draft_policy = create(:draft_policy)
    published_policy = create(:published_policy)
    archived_policy = create(:archived_policy)
    policy_topic = create(:policy_topic, policies: [draft_policy, published_policy, archived_policy])
    assert_equal [archived_policy], policy_topic.archived_policies
  end

  test "return policy topics bi-directionally related to specific policy topic" do
    policy_topic_1 = create(:policy_topic)
    policy_topic_2 = create(:policy_topic)
    policy_topic = create(:policy_topic, related_policy_topics: [policy_topic_1, policy_topic_2])

    assert_equal [policy_topic_1, policy_topic_2], policy_topic.related_policy_topics
    assert_equal [policy_topic], policy_topic_1.related_policy_topics
    assert_equal [policy_topic], policy_topic_2.related_policy_topics
  end

  test "should add related policy topics bi-directionally" do
    policy_topic_1 = create(:policy_topic)
    policy_topic_2 = create(:policy_topic)
    policy_topic = create(:policy_topic, related_policy_topics: [])

    policy_topic.update_attributes!(related_policy_topic_ids: [policy_topic_1.id, policy_topic_2.id])

    assert_equal [policy_topic_1, policy_topic_2], policy_topic.related_policy_topics
    assert_equal [policy_topic], policy_topic_1.related_policy_topics
    assert_equal [policy_topic], policy_topic_2.related_policy_topics
  end

  test "should remove related policy topics bi-directionally" do
    policy_topic_1 = create(:policy_topic)
    policy_topic_2 = create(:policy_topic)
    policy_topic = create(:policy_topic, related_policy_topics: [policy_topic_1, policy_topic_2])

    policy_topic.update_attributes!(related_policy_topic_ids: [])

    assert_equal [], policy_topic.related_policy_topics
    assert_equal [], policy_topic_1.related_policy_topics
    assert_equal [], policy_topic_2.related_policy_topics
  end


  test 'should return search index data suitable for Rummageable' do
    policy_topic = create(:policy_topic, name: "policy topic name", description: "topic description")

    assert_equal 'policy topic name', policy_topic.search_index['title']
    assert_equal "/government/policy-topics/#{policy_topic.slug}", policy_topic.search_index['link']
    assert_equal 'topic description', policy_topic.search_index['indexable_content']
    assert_equal 'policy-topic', policy_topic.search_index['format']
  end

  test 'should add policy topic to search index on creating' do
    topic = build(:policy_topic)

    search_index_data = stub('search index data')
    topic.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data)

    topic.save
  end

  test 'should add policy topic to search index on updating' do
    topic = create(:policy_topic)

    search_index_data = stub('search index data')
    topic.stubs(:search_index).returns(search_index_data)
    Rummageable.expects(:index).with(search_index_data)

    topic.name = 'different topic name'
    topic.save
  end

  test 'should remove policy topic from search index on destroying' do
    topic = create(:policy_topic)
    Rummageable.expects(:delete).with("/government/policy-topics/#{topic.slug}")
    topic.destroy
  end

  test 'should remove policy topic from search index on deleting' do
    topic = create(:policy_topic)
    Rummageable.expects(:delete).with("/government/policy-topics/#{topic.slug}")
    topic.delete!
  end

  test 'should return search index data for all policy topics' do
    create(:policy_topic)
    create(:policy_topic)
    create(:policy_topic)
    create(:policy_topic)

    results = PolicyTopic.search_index

    assert_equal 4, results.length
  end
end