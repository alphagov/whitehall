require "test_helper"

class TopicsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "shows topic title and description" do
    topic = create(:topic)
    get :show, id: topic
    assert_select ".page_title", text: topic.name
    assert_select ".topic .document", text: topic.description
  end

  test "shows published policies and their summaries" do
    published_policy = create(:published_policy, title: "policy-title", summary: "policy-summary")
    topic = create(:topic, policies: [published_policy])

    get :show, id: topic

    assert_select "#policies" do
      assert_select_object(published_policy) do
        assert_select ".article_title", text: "policy-title"
        assert_select ".summary", text: /policy-summary/
      end
    end
  end

  test "shows published specialist guides" do
    published_specialist_guide = create(:published_specialist_guide, title: "specialist-guide-title")
    topic = create(:topic, specialist_guides: [published_specialist_guide])

    get :show, id: topic

    assert_select "#specialist_guides" do
      assert_select_object(published_specialist_guide) do
        assert_select ".article_title", text: "specialist-guide-title"
      end
    end
  end

  test "shows featured policies and their summaries" do
    topic = create(:topic)
    policy = create(:published_policy, title: "policy-title", summary: "policy-summary")
    create(:topic_membership, topic: topic, policy: policy, featured: true)

    get :show, id: topic

    assert_select ".featured-policies" do
      assert_select_object(policy) do
        assert_select ".title", text: "policy-title"
        assert_select ".summary", text: /policy-summary/
      end
    end
  end

  test "doesn't show unpublished policies" do
    draft_policy = create(:draft_policy)
    topic = create(:topic, policies: [draft_policy])

    get :show, id: topic

    refute_select_object(draft_policy)
  end

  test "doesn't show unpublished specialist guides" do
    draft_specialist_guide = create(:draft_specialist_guide)
    topic = create(:topic, specialist_guides: [draft_specialist_guide])

    get :show, id: topic

    refute_select_object(draft_specialist_guide)
  end

  test "should not display an empty published policies section" do
    topic = create(:topic)
    get :show, id: topic
    refute_select "#policies"
  end

  test "show displays links to related topics" do
    related_topic_1 = create(:topic)
    related_topic_2 = create(:topic)
    unrelated_topic = create(:topic)
    topic = create(:topic, related_topics: [related_topic_1, related_topic_2])

    get :show, id: topic

    assert_select "#related_topics" do
      assert_select_object related_topic_1 do
        assert_select "a[href='#{topic_path(related_topic_1)}']"
      end
      assert_select_object related_topic_2 do
        assert_select "a[href='#{topic_path(related_topic_2)}']"
      end
      assert_select_object unrelated_topic, count: 0
    end
  end

  test "show does not display empty related topics section" do
    topic = create(:topic, related_topics: [])

    get :show, id: topic

    assert_select "#related_topics ul", count: 0
  end

  test "show displays recently changed documents relating to policies in the topic" do
    policy_1 = create(:published_policy)
    publication = create(:published_publication, related_policies: [policy_1])
    news_article = create(:published_news_article, related_policies: [policy_1])

    policy_2 = create(:published_policy)
    speech = create(:published_speech, related_policies: [policy_2])

    topic = create(:topic, policies: [policy_1, policy_2])

    get :show, id: topic

    assert_select "#recently-changed" do
      assert_select_object policy_1
      assert_select_object policy_2
      assert_select_object news_article
      assert_select_object publication
      assert_select_object speech
    end
  end

  test "show displays a maximum of 5 recently changed documents" do
    policy = create(:published_policy)
    6.times { create(:published_news_article, related_policies: [policy]) }
    topic = create(:topic, policies: [policy])

    get :show, id: topic

    assert_select "#recently-changed li", count: 5
  end

  test "show displays metadata about the recently changed documents" do
    published_at = Time.zone.now
    policy = create(:published_policy)
    speech = create(:published_speech, published_at: published_at, related_policies: [policy])

    topic = create(:topic, policies: [policy])

    get :show, id: topic

    assert_select "#recently-changed" do
      assert_select_object speech do
        assert_select '.metadata .document_type', text: "Speech"
        assert_select ".metadata .published_at[title='#{published_at.iso8601}']"
      end
    end
  end

  test "show displays recently changed documents including the policy in order of the edition's publication date with most recent first" do
    policy_1 = create(:published_policy, published_at: 2.weeks.ago)
    publication_1 = create(:published_publication, published_at: 6.weeks.ago, related_policies: [policy_1])
    news_article_1 = create(:published_news_article, published_at: 1.week.ago, related_policies: [policy_1])

    policy_2 = create(:published_policy, published_at: 5.weeks.ago)
    news_article_2 = create(:published_news_article, published_at: 4.weeks.ago, related_policies: [policy_2])
    publication_2 = create(:published_publication, published_at: 3.weeks.ago, related_policies: [policy_2])

    topic = create(:topic, policies: [policy_1, policy_2])

    get :show, id: topic

    expected = [news_article_1, policy_1, publication_2, news_article_2, policy_2, publication_1]
    actual = assigns(:recently_changed_documents)
    assert_equal expected, actual
  end

  test "show distinguishes between published and updated documents" do
    first_edition = create(:published_policy)
    updated_edition = create(:published_policy, published_at: Time.zone.now, first_published_at: 1.day.ago)

    topic = create(:topic, policies: [first_edition, updated_edition])

    get :show, id: topic

    assert_select_object first_edition do
      assert_select '.metadata', text: /Published/
    end

    assert_select_object updated_edition do
      assert_select '.metadata', text: /Updated/
    end
  end

  test "show should list organisation's working in the topic" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)
    topic = create(:topic, organisations: [first_organisation, second_organisation])

    get :show, id: topic

    assert_select ".meta" do
      assert_select_object first_organisation
      assert_select_object second_organisation
    end
  end

  test "should not display an empty organisation section" do
    topic = create(:topic)
    get :show, id: topic
    assert_select "#organisations", count: 0
  end

  test "should not show archived policies that were featured" do
    policy_1 = create(:published_policy, title: "some-policy")
    topic = create(:topic)
    topic.update_attributes(topic_memberships_attributes: [
      {topic_id: topic.id, featured: true, edition_id: policy_1.id}
    ])
    policy_1.publish_as(create(:user))
    policy_1.create_draft(create(:user))

    get :show, id: topic

    assert_select ".featured_policy a", text: "some-policy", count: 1
  end

  test "should show list of topics with published content" do
    topics = [0, 1, 2].map { |n| create(:topic, published_edition_count: n) }

    get :index

    refute_select_object(topics[0])
    assert_select_object(topics[1])
    assert_select_object(topics[2])
  end

  test "should not display an empty list of topics" do
    get :index

    refute_select ".topics"
  end

  test "shows a featured topic if one exists" do
    topic = create(:featured_topic)

    get :index

    assert_select "#featured-topics" do
      assert_select_object(topic)
    end
  end

  test "shows maximum of three featured topics by most recently updated" do
    older = create(:featured_topic, updated_at: 3.day.ago)
    newest = create(:featured_topic, updated_at: 1.day.ago)
    oldest = create(:featured_topic, updated_at: 4.day.ago)
    newer = create(:featured_topic, updated_at: 2.day.ago)

    get :index

    assert_select "#featured-topics .topic", count: 3
    assert_select "#featured-topics" do
      assert_select_object newest
      assert_select_object newer
      assert_select_object older
      refute_select_object oldest
    end
  end
end
