require 'test_helper'

class Admin::TopicsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  view_test "new displays topic form" do
    get :new

    assert_select "form#new_topic[action='#{admin_topics_path}']" do
      assert_select "input[name='topic[name]'][type='text']"
      assert_select "textarea[name='topic[description]']"
      assert_select "input[type='submit']"
    end
  end

  view_test "new displays related topics field" do
    get :new

    assert_select "form#new_topic" do
      assert_select "select[name*='topic[related_classification_ids]']"
    end
  end

  test "create should create a new topic" do
    attributes = attributes_for(:topic)

    post :create, topic: attributes

    assert topic = Topic.last
    assert_equal attributes[:name], topic.name
    assert_equal attributes[:description], topic.description
  end

  test "create should associate topics with topic" do
    first_topic = create(:topic)
    second_topic = create(:topic)
    attributes = attributes_for(:topic, name: "new-topic")

    post :create, topic: attributes.merge(
      related_classification_ids: [first_topic.id, second_topic.id]
    )

    assert topic = Topic.find_by_name("new-topic")
    assert_equal [first_topic, second_topic].to_set, topic.related_classifications.to_set
  end

  view_test "creating a topic without a name shows errors" do
    post :create, topic: { name: "", description: "description" }
    assert_select ".form-errors"
  end

  view_test "creating a topic without a description shows errors" do
    post :create, topic: { name: "name", description: "" }
    assert_select ".form-errors"
  end

  view_test "index lists topics in alphabetical order" do
    topic_c = create(:topic, name: "Topic C")
    topic_a = create(:topic, name: "Topic A")
    topic_b = create(:topic, name: "Topic B")

    get :index

    assert_select "#{record_css_selector(topic_a)} + #{record_css_selector(topic_b)} + #{record_css_selector(topic_c)}"
  end

  view_test "index should show related topics" do
    topic_1 = create(:topic)
    topic_2 = create(:topic)
    topic = create(:topic, related_classifications: [topic_1, topic_2])

    get :index

    assert_select_object(topic) do
      assert_select ".related" do
        assert_select_object topic_1
        assert_select_object topic_2
      end
    end
  end

  view_test "edit should display topic fields" do
    topic = create(:topic)

    get :edit, id: topic

    form_id = "edit_#{dom_id(topic)}"
    assert_select "form##{form_id}[action='#{admin_topic_path(topic)}']" do
      assert_select "input[name='topic[name]'][type='text']"
      assert_select "textarea[name='topic[description]']"
      assert_select "input[type='submit']"
    end
  end

  view_test "edit should display related topics field with selections" do
    topic_1 = create(:topic, name: "related-topic-1")
    topic_2 = create(:topic, name: "related-topic-2")
    topic = create(:topic, related_classifications: [topic_1, topic_2])

    get :edit, id: topic

    form_id = "edit_#{dom_id(topic)}"
    assert_select "form##{form_id}" do
      assert_select "select[name*='topic[related_classification_ids]']" do
        assert_select "option[selected='selected']", text: "related-topic-1"
        assert_select "option[selected='selected']", text: "related-topic-2"
      end
    end
  end

  view_test "edit should include all topics except edited topic in related topic options" do
    topic_1 = create(:topic, name: "topic-1")
    topic_2 = create(:topic, name: "topic-2")
    topic = create(:topic, name: "topic-for-editing")

    get :edit, id: topic

    form_id = "edit_#{dom_id(topic)}"
    assert_select "form##{form_id}" do
      assert_select "select[name*='topic[related_classification_ids]']" do
        assert_select "option", text: "topic-1"
        assert_select "option", text: "topic-2"
        assert_select "option", text: "topic-for-editing", count: 0
      end
    end
  end

  test "updating should save modified topic attributes" do
    topic = create(:topic)

    put :update, id: topic, topic: {
      name: "new-name",
      description: "new-description"
    }

    topic.reload
    assert_equal "new-name", topic.name
    assert_equal "new-description", topic.description
  end

  test "update should associate related topics with topic" do
    first_topic = create(:topic)
    second_topic = create(:topic)

    topic = create(:topic, related_classifications: [first_topic])

    put :update, id: topic, topic: {
      related_classification_ids: [second_topic.id]
    }

    topic.reload
    assert_equal [second_topic], topic.related_classifications
  end

  test "update should remove all related topics if none specified" do
    first_topic = create(:topic)
    second_topic = create(:topic)

    topic = create(:topic,
      related_classification_ids: [first_topic.id, second_topic.id]
    )

    put :update, id: topic, topic: {}

    topic.reload
    assert_equal [], topic.related_classifications
  end

  view_test "updating without a description shows errors" do
    topic = create(:topic)
    put :update, id: topic.id, topic: {name: "Blah", description: ""}

    assert_select ".form-errors"
  end

  view_test "editing only shows published editions for ordering" do
    topic = create(:topic)
    policy = create(:published_policy, topics: [topic])
    draft_policy = create(:draft_policy, topics: [topic])
    published_association = topic.classification_memberships.where(edition_id: policy.id).first
    draft_association = topic.classification_memberships.where(edition_id: draft_policy.id).first

    get :edit, id: topic.id

    assert_select "#policy_order input[type=hidden][value=#{published_association.id}]"
    refute_select "#policy_order input[type=hidden][value=#{draft_association.id}]"
  end

  test "allows updating of edition ordering" do
    topic = create(:topic)
    policy = create(:policy, topics: [topic])
    association = topic.classification_memberships.first

    put :update, id: topic.id, topic: {name: "Blah", description: "Blah", classification_memberships_attributes: {
      "0" => {id: association.id, ordering: "4"}
    }}

    assert_equal 4, association.reload.ordering
  end

  test "should be able to destroy a destroyable topic" do
    topic = create(:topic)
    delete :destroy, id: topic.id

    assert_response :redirect
    assert_equal "Topic destroyed", flash[:notice]
    assert topic.reload.deleted?
  end

  view_test "should indicate that a topic is not destroyable when editing" do
    topic_with_published_policy = create(:topic, policies: [build(:published_policy, title: "thingies")])

    get :edit, id: topic_with_published_policy.id
    assert_select ".policies_preventing_destruction" do
      assert_select "a", "thingies"
      assert_select ".document_state", "(published policy)"
    end
  end

  test "destroying a topic which has associated content" do
    topic_with_published_policy = create(:topic, policies: [build(:published_policy)])

    delete :destroy, id: topic_with_published_policy.id
    assert_equal "Cannot destroy Topic with associated content", flash[:alert]
  end
end
