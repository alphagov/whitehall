require 'test_helper'

class Admin::PolicyTopicsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "new displays policy topic form" do
    get :new

    assert_select "form#new_policy_topic[action='#{admin_policy_topics_path}']" do
      assert_select "input[name='policy_topic[name]'][type='text']"
      assert_select "textarea[name='policy_topic[description]']"
      assert_select "input[type='submit']"
    end
  end

  test "new displays related policy topics field" do
    get :new

    assert_select "form#new_policy_topic" do
      assert_select "select[name*='policy_topic[related_policy_topic_ids]']"
    end
  end

  test "create should create a new policy topic" do
    attributes = attributes_for(:policy_topic)

    post :create, policy_topic: attributes

    assert policy_topic = PolicyTopic.last
    assert_equal attributes[:name], policy_topic.name
    assert_equal attributes[:description], policy_topic.description
  end

  test "create should associate policy topics with policy topic" do
    first_policy_topic = create(:policy_topic)
    second_policy_topic = create(:policy_topic)
    attributes = attributes_for(:policy_topic, name: "new-policy-topic")

    post :create, policy_topic: attributes.merge(
      related_policy_topic_ids: [first_policy_topic.id, second_policy_topic.id]
    )

    assert policy_topic = PolicyTopic.find_by_name("new-policy-topic")
    assert_equal [first_policy_topic, second_policy_topic].to_set, policy_topic.related_policy_topics.to_set
  end

  test "creating a policy topic without a name shows errors" do
    post :create, policy_topic: { name: "", description: "description" }
    assert_select ".form-errors"
  end

  test "creating a policy topic without a description shows errors" do
    post :create, policy_topic: { name: "name", description: "" }
    assert_select ".form-errors"
  end

  test "index lists policy topics in alphabetical order" do
    policy_topic_c = create(:policy_topic, name: "Policy Area C")
    policy_topic_a = create(:policy_topic, name: "Policy Area A")
    policy_topic_b = create(:policy_topic, name: "Policy Area B")

    get :index

    assert_select "#{record_css_selector(policy_topic_a)} + #{record_css_selector(policy_topic_b)} + #{record_css_selector(policy_topic_c)}"
  end

  test "index should show related policy topics" do
    policy_topic_1 = create(:policy_topic)
    policy_topic_2 = create(:policy_topic)
    policy_topic = create(:policy_topic, related_policy_topics: [policy_topic_1, policy_topic_2])

    get :index

    assert_select_object(policy_topic) do
      assert_select ".related" do
        assert_select_object policy_topic_1
        assert_select_object policy_topic_2
      end
    end
  end

  test "indexing shows a feature or unfeature button for policy topics" do
    featured_policy_topic = create(:policy_topic, featured: true)
    unfeatured_policy_topic = create(:policy_topic, featured: false)
    get :index

    assert_select_object featured_policy_topic do
      assert_select "form[action='#{unfeature_admin_policy_topic_path(featured_policy_topic)}']" do
        assert_select "input[type='submit'][value='No Longer Feature']"
      end
      refute_select "form[action='#{feature_admin_policy_topic_path(featured_policy_topic)}']"
    end

    assert_select_object unfeatured_policy_topic do
      assert_select "form[action='#{feature_admin_policy_topic_path(unfeatured_policy_topic)}']" do
        assert_select "input[type='submit'][value='Feature Policy Area']"
      end
      refute_select "form[action='#{unfeature_admin_policy_topic_path(unfeatured_policy_topic)}']"
    end
  end

  test "edit should display policy topic fields" do
    policy_topic = create(:policy_topic)

    get :edit, id: policy_topic

    form_id = "edit_#{dom_id(policy_topic)}"
    assert_select "form##{form_id}[action='#{admin_policy_topic_path(policy_topic)}']" do
      assert_select "input[name='policy_topic[name]'][type='text']"
      assert_select "textarea[name='policy_topic[description]']"
      assert_select "input[type='submit']"
    end
  end

  test "edit should display related policy topics field with selections" do
    policy_topic_1 = create(:policy_topic, name: "related-policy-topic-1")
    policy_topic_2 = create(:policy_topic, name: "related-policy-topic-2")
    policy_topic = create(:policy_topic, related_policy_topics: [policy_topic_1, policy_topic_2])

    get :edit, id: policy_topic

    form_id = "edit_#{dom_id(policy_topic)}"
    assert_select "form##{form_id}" do
      assert_select "select[name*='policy_topic[related_policy_topic_ids]']" do
        assert_select "option[selected='selected']", text: "related-policy-topic-1"
        assert_select "option[selected='selected']", text: "related-policy-topic-2"
      end
    end
  end

  test "edit should include all policy topics except edited policy topic in related policy topic options" do
    policy_topic_1 = create(:policy_topic, name: "policy-topic-1")
    policy_topic_2 = create(:policy_topic, name: "policy-topic-2")
    policy_topic = create(:policy_topic, name: "policy-topic-for-editing")

    get :edit, id: policy_topic

    form_id = "edit_#{dom_id(policy_topic)}"
    assert_select "form##{form_id}" do
      assert_select "select[name*='policy_topic[related_policy_topic_ids]']" do
        assert_select "option", text: "policy-topic-1"
        assert_select "option", text: "policy-topic-2"
        assert_select "option", text: "policy-topic-for-editing", count: 0
      end
    end
  end

  test "updating should save modified policy topic attributes" do
    policy_topic = create(:policy_topic)

    put :update, id: policy_topic, policy_topic: {
      name: "new-name",
      description: "new-description"
    }

    policy_topic.reload
    assert_equal "new-name", policy_topic.name
    assert_equal "new-description", policy_topic.description
  end

  test "update should associate related policy topics with policy topic" do
    first_policy_topic = create(:policy_topic)
    second_policy_topic = create(:policy_topic)

    policy_topic = create(:policy_topic, related_policy_topics: [first_policy_topic])

    put :update, id: policy_topic, policy_topic: {
      related_policy_topic_ids: [second_policy_topic.id]
    }

    policy_topic.reload
    assert_equal [second_policy_topic], policy_topic.related_policy_topics
  end

  test "update should remove all related policy topics if none specified" do
    first_policy_topic = create(:policy_topic)
    second_policy_topic = create(:policy_topic)

    policy_topic = create(:policy_topic,
      related_policy_topic_ids: [first_policy_topic.id, second_policy_topic.id]
    )

    put :update, id: policy_topic, policy_topic: {}

    policy_topic.reload
    assert_equal [], policy_topic.related_policy_topics
  end

  test "updating without a description shows errors" do
    policy_topic = create(:policy_topic)
    put :update, id: policy_topic.id, policy_topic: {name: "Blah", description: ""}

    assert_select ".form-errors"
  end

  test "editing only shows published editions for ordering" do
    policy_topic = create(:policy_topic)
    policy = create(:published_policy, policy_topics: [policy_topic])
    draft_policy = create(:draft_policy, policy_topics: [policy_topic])
    published_association = policy_topic.policy_topic_memberships.where(policy_id: policy.id).first
    draft_association = policy_topic.policy_topic_memberships.where(policy_id: draft_policy.id).first

    get :edit, id: policy_topic.id

    assert_select "#policy_order input[type=hidden][value=#{published_association.id}]"
    refute_select "#policy_order input[type=hidden][value=#{draft_association.id}]"
  end

  test "allows updating of edition ordering" do
    policy_topic = create(:policy_topic)
    policy = create(:policy, policy_topics: [policy_topic])
    association = policy_topic.policy_topic_memberships.first

    put :update, id: policy_topic.id, policy_topic: {name: "Blah", description: "Blah", policy_topic_memberships_attributes: {
      "0" => {id: association.id, ordering: "4"}
    }}

    assert_equal 4, association.reload.ordering
  end

  test "should be able to destroy a destroyable policy topic" do
    policy_topic = create(:policy_topic)
    delete :destroy, id: policy_topic.id

    assert_response :redirect
    assert_equal "Policy topic destroyed", flash[:notice]
    assert policy_topic.reload.deleted?
  end

  test "should indicate that a policy topic is not destroyable when editing" do
    policy_topic_with_published_policy = create(:policy_topic, policies: [build(:published_policy, title: "thingies")])

    get :edit, id: policy_topic_with_published_policy.id
    assert_select ".policies_preventing_destruction" do
      assert_select "a", "thingies"
      assert_select ".document_state", "(published policy)"
    end
  end

  test "destroying a policy topic which has associated content" do
    policy_topic_with_published_policy = create(:policy_topic, policies: [build(:published_policy)])

    delete :destroy, id: policy_topic_with_published_policy.id
    assert_equal "Cannot destroy policy topic with associated content", flash[:alert]
  end

  test "featuring sets policy topic featured flag" do
    policy_topic = create(:policy_topic, featured: false, policies: [build(:published_policy)])
    post :feature, id: policy_topic
    assert policy_topic.reload.featured?
  end

  test "featuring redirects to index and informs user the policy topic is now featured" do
    policy_topic = create(:policy_topic, featured: false, policies: [build(:published_policy)])
    post :feature, id: policy_topic
    assert_redirected_to admin_policy_topics_path
    assert_equal flash[:notice], "The policy topic #{policy_topic.name} is now featured"
  end

  test "featuring is prohibited when a policy topic has no published policies" do
    policy_topic = create(:policy_topic, featured: false, policies: [])
    post :feature, id: policy_topic
    assert_redirected_to admin_policy_topics_path
    assert_equal "The policy topic #{policy_topic.name} cannot be featured because it has no published policies", flash[:alert]
    refute policy_topic.reload.featured?
  end

  test "unfeaturing unsets policy topic featured flag" do
    policy_topic = create(:policy_topic, featured: true)
    post :unfeature, id: policy_topic
    refute policy_topic.reload.featured?
  end

  test "unfeaturing redirects to index and informs user the policy topic is no longer featured" do
    policy_topic = create(:policy_topic, featured: false)
    post :unfeature, id: policy_topic
    assert_redirected_to admin_policy_topics_path
    assert_equal flash[:notice], "The policy topic #{policy_topic.name} is no longer featured"
  end
end