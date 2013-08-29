require 'test_helper'

class TopicTest < ActiveSupport::TestCase

  test "should allow association with policies" do
    policy = create(:draft_policy)
    topic = create(:topic, policies: [policy])

    assert_equal [topic], policy.reload.topics
  end

  test "should allow association with detailed guides" do
    detailed_guide = create(:draft_detailed_guide)
    topic = create(:topic, detailed_guides: [detailed_guide])

    assert_equal [topic], detailed_guide.reload.topics
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

  test "should not include apostrophes in slug" do
    topic = create(:topic, name: "Bob's bike")
    assert_equal 'bobs-bike', topic.slug
  end

  test "should allow setting ordering of policies" do
    topic = create(:topic)
    first_policy = create(:policy, topics: [topic])
    second_policy = create(:policy, topics: [topic])
    first_association = topic.classification_memberships.find_by_edition_id(first_policy.id)
    second_association = topic.classification_memberships.find_by_edition_id(second_policy.id)

    topic.update_attributes(classification_memberships_attributes: {
      first_association.id => {id: first_association.id, edition_id: first_policy.id, ordering: "2"},
      second_association.id => {id: second_association.id, edition_id: second_policy.id, ordering: "1"}
    })

    assert_equal 2, first_association.reload.ordering
    assert_equal 1, second_association.reload.ordering
  end

  test "return published editions relating to policies in the topic" do
    policy = create(:published_policy)
    publication_1 = create(:published_publication, related_editions: [policy])
    topic = create(:topic, policies: [policy])

    assert_equal [publication_1], topic.published_related_editions
  end

  test "return published editions relating to policies in the topic without duplicates" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    publication_1 = create(:published_publication, related_editions: [policy_1])
    publication_2 = create(:published_publication, related_editions: [policy_1, policy_2])
    topic = create(:topic, policies: [policy_1, policy_2])

    assert_equal [publication_1, publication_2], topic.published_related_editions
  end

  test "return only *published* editions relating to policies in the topic" do
    published_policy = create(:published_policy)
    create(:draft_publication, related_editions: [published_policy])
    topic = create(:topic, policies: [published_policy])

    assert_equal [], topic.published_related_editions
  end

  test "return editions relating to only *published* policies in the topic" do
    draft_policy = create(:draft_policy)
    create(:published_publication, related_editions: [draft_policy])
    topic = create(:topic, policies: [draft_policy])

    assert_equal [], topic.published_related_editions
  end

  test "return published editions relating from policies in the topic without duplicates" do
    policy_1 = create(:published_policy)
    policy_2 = create(:published_policy)
    publication_1 = create(:published_publication, related_editions: [policy_1, policy_2])
    publication_2 = create(:published_publication, related_editions: [policy_1])
    topic = create(:topic, policies: [policy_1, policy_2])

    assert_equal [publication_1, publication_2], topic.published_related_editions
  end

  test "return only *published* editions relating from policies in the topic" do
    published_policy = create(:published_policy)
    draft_publication = create(:draft_publication, related_editions: [published_policy])
    topic = create(:topic, policies: [published_policy])

    assert_equal [], topic.published_related_editions
  end

  test "return editions relating from only *published* policies in the topic" do
    draft_policy = create(:draft_policy)
    published_publication = create(:published_publication, related_editions: [draft_policy])
    topic = create(:topic, policies: [draft_policy])

    assert_equal [], topic.published_related_editions
  end

  test "should be deletable if all the associated policies are archived" do
    topic = create(:topic, policies: [create(:archived_policy)])
    assert topic.destroyable?
    topic.delete!
    assert topic.deleted?
  end

  test "should not be deletable if there are non-archived associated policies" do
    topic = create(:topic, policies: [create(:policy)])
    refute topic.destroyable?
    topic.delete!
    refute topic.deleted?
  end

  test "should return the list of archived policies" do
    draft_policy = create(:draft_policy)
    published_policy = create(:published_policy)
    archived_policy = create(:archived_policy)
    topic = create(:topic, policies: [draft_policy, published_policy, archived_policy])
    assert_equal [archived_policy], topic.archived_policies
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

  test 'should filter out topics without any published detailed guides related directly via topics' do
    has_nothing = create(:topic)
    create(:draft_detailed_guide, topics: [has_draft_detailed_guide = create(:topic)])
    create(:published_detailed_guide, topics: [has_published_detailed_guide = create(:topic)])

    topics = Topic.with_related_detailed_guides

    assert_includes topics, has_published_detailed_guide
    refute_includes topics, has_draft_detailed_guide
    refute_includes topics, has_nothing
  end

  test 'should filter out topics without any published publications or consultations related via published policies' do
    has_nothing = create(:topic)
    create(:published_policy, topics: [has_published_policy = create(:topic)])
    create(:draft_publication, related_editions: [create(:published_policy, topics: [has_draft_publication_via_published_policy = create(:topic)])])
    create(:draft_consultation, related_editions: [create(:published_policy, topics: [has_draft_consultation_via_published_policy = create(:topic)])])
    create(:published_publication, related_editions: [create(:draft_policy, topics: [has_published_publication_via_draft_policy = create(:topic)])])
    create(:published_consultation, related_editions: [create(:draft_policy, topics: [has_published_consultation_via_draft_policy = create(:topic)])])
    create(:published_consultation, related_editions: [create(:published_policy, topics: [has_published_consultation_via_published_policy = create(:topic)])])
    create(:published_publication, related_editions: [create(:published_policy, topics: [has_published_publication_via_published_policy = create(:topic)])])

    topics = Topic.with_related_publications

    assert_includes topics, has_published_publication_via_published_policy
    assert_includes topics, has_published_consultation_via_published_policy
    refute_includes topics, has_published_publication_via_draft_policy
    refute_includes topics, has_published_consultation_via_draft_policy
    refute_includes topics, has_draft_publication_via_published_policy
    refute_includes topics, has_draft_consultation_via_published_policy
    refute_includes topics, has_published_policy
    refute_includes topics, has_nothing
  end

  test 'should filter out topics without any published announcements related via published policies' do
    has_nothing = create(:topic)
    create(:published_policy, topics: [has_published_policy = create(:topic)])
    create(:draft_news_article, related_editions: [create(:published_policy, topics: [has_draft_news_article_via_published_policy = create(:topic)])])
    create(:draft_speech, related_editions: [create(:published_policy, topics: [has_draft_speech_via_published_policy = create(:topic)])])
    create(:published_news_article, related_editions: [create(:draft_policy, topics: [has_published_news_article_via_draft_policy = create(:topic)])])
    create(:published_speech, related_editions: [create(:draft_policy, topics: [has_published_speech_via_draft_policy = create(:topic)])])
    create(:published_consultation, related_editions: [create(:published_policy, topics: [has_published_consultation_via_published_policy = create(:topic)])])
    create(:published_news_article, related_editions: [create(:published_policy, topics: [has_published_news_article_via_published_policy = create(:topic)])])
    create(:published_speech, related_editions: [create(:published_policy, topics: [has_published_speech_via_published_policy = create(:topic)])])

    topics = Topic.with_related_announcements

    assert_includes topics, has_published_speech_via_published_policy
    assert_includes topics, has_published_news_article_via_published_policy
    refute_includes topics, has_published_consultation_via_published_policy
    refute_includes topics, has_published_news_article_via_draft_policy
    refute_includes topics, has_published_speech_via_draft_policy
    refute_includes topics, has_draft_news_article_via_published_policy
    refute_includes topics, has_draft_speech_via_published_policy
    refute_includes topics, has_published_policy
    refute_includes topics, has_nothing
  end

  test 'should not have duplicate topics in list of topics with announcements' do
    topic = create(:topic)
    policy1 = create(:published_policy, topics: [topic])
    policy2 = create(:published_policy, topics: [topic])
    create(:published_speech, related_editions: [policy1])
    create(:published_speech, related_editions: [policy1])
    create(:published_speech, related_editions: [policy2])

    assert_equal [topic], Topic.with_related_announcements
  end

  test 'should not have duplicate topics in list of topics with detailed guides' do
    topic = create(:topic)
    create(:published_detailed_guide, topics: [topic])
    create(:published_detailed_guide, topics: [topic])

    assert_equal [topic], Topic.with_related_detailed_guides
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

  test "should return all published policies and their published related editions in reverse chronological order" do
    topic = create(:topic)
    old_published_policy = create(:published_policy, topics: [topic], first_published_at: 1.month.ago)
    new_published_policy = create(:published_policy, topics: [topic], first_published_at: 1.day.ago)
    news_article = create(:published_news_article, related_editions: [old_published_policy], first_published_at: 1.week.ago)
    publication = create(:published_publication, related_editions: [new_published_policy], first_published_at: 2.weeks.ago)
    speech = create(:published_speech, related_editions: [new_published_policy], first_published_at: 3.weeks.ago)

    assert_equal [new_published_policy, news_article, publication, speech, old_published_policy], topic.recently_changed_documents
  end
end
