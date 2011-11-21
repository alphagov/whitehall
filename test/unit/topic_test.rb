require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test 'should be valid when built from the factory' do
    topic = build(:topic)
    assert topic.valid?
  end

  test 'should be invalid without a name' do
    topic = build(:topic, name: nil)
    refute topic.valid?
  end

  test 'should be invalid without a unique name' do
    existing_topic = create(:topic)
    new_topic = build(:topic, name: existing_topic.name)
    refute new_topic.valid?
  end

  test 'should be invalid without a description' do
    topic = build(:topic, description: nil)
    refute topic.valid?
  end

  test "should return a list of topics with published documents" do
    topic_with_published_policy = create(:topic, documents: [build(:published_policy)])
    topic_with_published_publication = create(:topic, documents: [build(:published_publication)])
    topic_with_published_policy_and_publication = create(:topic, documents: [build(:published_policy), build(:published_publication)])
    create(:topic, documents: [build(:draft_policy)])
    create(:topic, documents: [build(:draft_publication)])

    expected = [topic_with_published_policy, topic_with_published_publication, topic_with_published_policy_and_publication]
    assert_equal expected, Topic.with_published_documents
  end

  test "should set a slug from the topic name" do
    topic = create(:topic, name: 'Love all the people')
    assert_equal 'love-all-the-people', topic.slug
  end

  test "should not change the slug when the name is changed" do
    topic = create(:topic, name: 'Love all the people')
    topic.update_attributes(name: 'Hold hands')
    assert_equal 'love-all-the-people', topic.slug
  end

  test "should concatenate words containing apostrophes" do
    topic = create(:topic, name: "Bob's bike")
    assert_equal 'bobs-bike', topic.slug
  end

  test "should allow setting ordering of associated documents" do
    topic = create(:topic)
    first_policy = create(:policy, topics: [topic])
    second_policy = create(:policy, topics: [topic])
    first_association = topic.document_topics.find_by_document_id(first_policy.id)
    second_association = topic.document_topics.find_by_document_id(second_policy.id)

    topic.update_attributes(document_topics_attributes: {
      first_association.id => {id: first_association.id, document_id: first_policy.id, ordering: "2"},
      second_association.id => {id: second_association.id, document_id: second_policy.id, ordering: "1"}
    })

    assert_equal 2, first_association.reload.ordering
    assert_equal 1, second_association.reload.ordering
  end

  test "should not be destroyable when it has associated content" do
    topic_with_published_policy = create(:topic, documents: [build(:published_policy)])
    refute topic_with_published_policy.destroyable?
    assert_equal false, topic_with_published_policy.destroy
  end

  test ".featured includes all featured topics" do
    topic = create(:topic, featured: true)
    assert Topic.featured.include?(topic)
  end

  test ".featured excludes unfeatured topics" do
    topic = create(:topic, featured: false)
    refute Topic.featured.include?(topic)
  end

  test "return published documents relating to policies in the topic without duplicates" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    publication_1 = create(:published_publication, documents_related_to: [policy_1])
    publication_2 = create(:published_publication, documents_related_to: [policy_1, policy_2])
    topic = create(:topic, documents: [policy_1, policy_2])

    assert_equal [publication_1, publication_2], topic.published_related_documents
  end

  test "return only *published* documents relating to policies in the topic" do
    published_policy = create(:published_policy)
    create(:draft_publication, documents_related_to: [published_policy])
    topic = create(:topic, documents: [published_policy])

    assert_equal [], topic.published_related_documents
  end

  test "return documents relating to only *published* policies in the topic" do
    draft_policy = create(:draft_policy)
    create(:published_publication, documents_related_to: [draft_policy])
    topic = create(:topic, documents: [draft_policy])

    assert_equal [], topic.published_related_documents
  end

  test "return published documents relating from policies in the topic without duplicates" do
    publication_1 = create(:published_publication)
    publication_2 = create(:published_publication)
    policy_1 = create(:published_policy, documents_related_to: [publication_1])
    policy_2 = create(:published_policy, documents_related_to: [publication_1, publication_2])
    topic = create(:topic, documents: [policy_1, policy_2])

    assert_equal [publication_1, publication_2], topic.published_related_documents
  end

  test "return only *published* documents relating from policies in the topic" do
    draft_publication = create(:draft_publication)
    published_policy = create(:published_policy, documents_related_to: [draft_publication])
    topic = create(:topic, documents: [published_policy])

    assert_equal [], topic.published_related_documents
  end

  test "return documents relating from only *published* policies in the topic" do
    published_publication = create(:published_publication)
    draft_policy = create(:draft_policy, documents_related_to: [published_publication])
    topic = create(:topic, documents: [draft_policy])

    assert_equal [], topic.published_related_documents
  end

end