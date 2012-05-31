require "test_helper"

class PolicyTopicsControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test "shows policy topic title and description" do
    policy_topic = create(:policy_topic)
    get :show, id: policy_topic
    assert_select ".page_title", text: policy_topic.name
    assert_select ".policy-topic .document", text: policy_topic.description
  end

  test "shows published policies and their summaries" do
    published_policy = create(:published_policy, title: "policy-title", summary: "policy-summary")
    policy_topic = create(:policy_topic, policies: [published_policy])

    get :show, id: policy_topic

    assert_select "#policies" do
      assert_select_object(published_policy) do
        assert_select ".article_title", text: "policy-title"
        assert_select ".summary", text: /policy-summary/
      end
    end
  end

  test "shows featured policies and their summaries" do
    policy_topic = create(:policy_topic)
    policy = create(:published_policy, title: "policy-title", summary: "policy-summary")
    create(:policy_topic_membership, policy_topic: policy_topic, policy: policy, featured: true)

    get :show, id: policy_topic

    assert_select ".featured-policies" do
      assert_select_object(policy) do
        assert_select ".title", text: "policy-title"
        assert_select ".summary", text: /policy-summary/
      end
    end
  end

  test "doesn't show unpublished policies" do
    draft_policy = create(:draft_policy)
    policy_topic = create(:policy_topic, policies: [draft_policy])

    get :show, id: policy_topic

    refute_select_object(draft_policy)
  end

  test "should not display an empty published policies section" do
    policy_topic = create(:policy_topic)
    get :show, id: policy_topic
    refute_select "#policies"
  end

  test "show displays links to related policy topics" do
    related_policy_topic_1 = create(:policy_topic)
    related_policy_topic_2 = create(:policy_topic)
    unrelated_policy_topic = create(:policy_topic)
    policy_topic = create(:policy_topic, related_policy_topics: [related_policy_topic_1, related_policy_topic_2])

    get :show, id: policy_topic

    assert_select "#related_policy_topics" do
      assert_select_object related_policy_topic_1 do
        assert_select "a[href='#{policy_topic_path(related_policy_topic_1)}']"
      end
      assert_select_object related_policy_topic_2 do
        assert_select "a[href='#{policy_topic_path(related_policy_topic_2)}']"
      end
      assert_select_object unrelated_policy_topic, count: 0
    end
  end

  test "show does not display empty related policy topics section" do
    policy_topic = create(:policy_topic, related_policy_topics: [])

    get :show, id: policy_topic

    assert_select "#related_policy_topics ul", count: 0
  end

  test "show displays recently changed documents relating to policies in the policy topic" do
    policy_1 = create(:published_policy)
    publication = create(:published_publication, related_policies: [policy_1])
    news_article = create(:published_news_article, related_policies: [policy_1])

    policy_2 = create(:published_policy)
    speech = create(:published_speech, related_policies: [policy_2])

    policy_topic = create(:policy_topic, policies: [policy_1, policy_2])

    get :show, id: policy_topic

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
    policy_topic = create(:policy_topic, policies: [policy])

    get :show, id: policy_topic

    assert_select "#recently-changed li", count: 5
  end

  test "show displays metadata about the recently changed documents" do
    published_at = Time.zone.now
    policy = create(:published_policy)
    speech = create(:published_speech, published_at: published_at, related_policies: [policy])

    policy_topic = create(:policy_topic, policies: [policy])

    get :show, id: policy_topic

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

    policy_topic = create(:policy_topic, policies: [policy_1, policy_2])

    get :show, id: policy_topic

    expected = [news_article_1, policy_1, publication_2, news_article_2, policy_2, publication_1]
    actual = assigns(:recently_changed_documents)
    assert_equal expected, actual
  end

  test "show distinguishes between published and updated documents" do
    first_edition = create(:published_policy)
    updated_edition = create(:published_policy, published_at: Time.zone.now, first_published_at: 1.day.ago)

    policy_topic = create(:policy_topic, policies: [first_edition, updated_edition])

    get :show, id: policy_topic

    assert_select_object first_edition do
      assert_select '.metadata', text: /Published/
    end

    assert_select_object updated_edition do
      assert_select '.metadata', text: /Updated/
    end
  end

  test "show should list organisation's working in the policy topic" do
    first_organisation = create(:organisation)
    second_organisation = create(:organisation)
    policy_topic = create(:policy_topic, organisations: [first_organisation, second_organisation])

    get :show, id: policy_topic

    assert_select ".meta" do
      assert_select_object first_organisation
      assert_select_object second_organisation
    end
  end

  test "should not display an empty organisation section" do
    policy_topic = create(:policy_topic)
    get :show, id: policy_topic
    assert_select "#organisations", count: 0
  end

  test "should not show archived policies that were featured" do
    policy_1 = create(:published_policy, title: "some-policy")
    policy_topic = create(:policy_topic)
    policy_topic.update_attributes(policy_topic_memberships_attributes: [
      {policy_topic_id: policy_topic.id, featured: true, policy_id: policy_1.id}
    ])
    policy_1.publish_as(create(:user))
    policy_1.create_draft(create(:user))

    get :show, id: policy_topic

    assert_select ".featured_policy a", text: "some-policy", count: 1
  end

  test "should show list of policy topics with published documents" do
    policy_topic_1, policy_topic_2 = create(:policy_topic), create(:policy_topic)
    PolicyTopic.stubs(:with_published_policies).returns([policy_topic_1, policy_topic_2])

    get :index

    assert_select_object(policy_topic_1)
    assert_select_object(policy_topic_2)
  end

  test "should not display an empty list of policy topics" do
    PolicyTopic.stubs(:with_published_policies).returns([])

    get :index

    refute_select ".policy_topics"
  end

  test "shows a featured policy topic if one exists" do
    policy_topic = create(:featured_policy_topic)

    get :index

    assert_select "#featured-policytopics" do
      assert_select_object(policy_topic)
    end
  end

  test "shows maximum of three featured policy topics by most recently updated" do
    older = create(:featured_policy_topic, updated_at: 3.day.ago)
    newest = create(:featured_policy_topic, updated_at: 1.day.ago)
    oldest = create(:featured_policy_topic, updated_at: 4.day.ago)
    newer = create(:featured_policy_topic, updated_at: 2.day.ago)

    get :index

    assert_select "#featured-policytopics .policy_topic", count: 3
    assert_select "#featured-policytopics" do
      assert_select_object newest
      assert_select_object newer
      assert_select_object older
      refute_select_object oldest
    end
  end
end