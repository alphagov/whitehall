require 'test_helper'

class Admin::TopicsControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test_controller_is_a Admin::BaseController

  test "creating a topic without a name shows errors" do
    post :create, topic: { name: "", description: "description" }
    assert_select ".form-errors"
  end

  test "creating a topic without a description shows errors" do
    post :create, topic: { name: "name", description: "" }
    assert_select ".form-errors"
  end

  test "indexing shows a feature or unfeature button for topics" do
    featured_topic = create(:topic, featured: true)
    unfeatured_topic = create(:topic, featured: false)
    get :index

    assert_select_object featured_topic do
      assert_select "form[action='#{unfeature_admin_topic_path(featured_topic)}']" do
        assert_select "input[type='submit'][value='No Longer Feature']"
      end
      assert_select "form[action='#{feature_admin_topic_path(featured_topic)}']", count: 0
    end

    assert_select_object unfeatured_topic do
      assert_select "form[action='#{feature_admin_topic_path(unfeatured_topic)}']" do
        assert_select "input[type='submit'][value='Feature Topic']"
      end
      assert_select "form[action='#{unfeature_admin_topic_path(unfeatured_topic)}']", count: 0
    end
  end

  test "updating without a description shows errors" do
    topic = create(:topic)
    put :update, id: topic.id, topic: {name: "Blah", description: ""}

    assert_select ".form-errors"
  end

  test "editing only shows published documents for ordering" do
    topic = create(:topic)
    policy = create(:published_policy, topics: [topic])
    draft_policy = create(:draft_policy, topics: [topic])
    published_association = topic.document_topics.where(document_id: policy.id).first
    draft_association = topic.document_topics.where(document_id: draft_policy.id).first

    get :edit, id: topic.id

    assert_select "#policy_order input[type=hidden][value=#{published_association.id}]"
    assert_select "#policy_order input[type=hidden][value=#{draft_association.id}]", false
  end

  test "allows updating of document ordering" do
    topic = create(:topic)
    policy = create(:policy, topics: [topic])
    association = topic.document_topics.first

    put :update, id: topic.id, topic: {name: "Blah", description: "Blah", document_topics_attributes: {
      "0" => {id: association.id, ordering: "4"}
    }}

    assert_equal 4, association.reload.ordering
  end

  test "should be able to destroy a destroyable topic" do
    topic = create(:topic)
    delete :destroy, id: topic.id

    assert_response :redirect
    assert_equal "Topic destroyed", flash[:notice]
  end

  test "destroying a topic which has associated content" do
    topic_with_published_policy = create(:topic, documents: [build(:published_policy)])

    delete :destroy, id: topic_with_published_policy.id
    assert_equal "Cannot destroy topic with associated content", flash[:alert]
  end

  test "featuring sets topic featured flag" do
    topic = create(:topic, featured: false)
    post :feature, id: topic
    assert topic.reload.featured?
  end

  test "featuring redirects to index and informs user the topic is now featured" do
    topic = create(:topic, featured: false)
    post :feature, id: topic
    assert_redirected_to admin_topics_path
    assert_equal flash[:notice], "The topic #{topic.name} is now featured"
  end

  test "unfeaturing unsets topic featured flag" do
    topic = create(:topic, featured: true)
    post :unfeature, id: topic
    refute topic.reload.featured?
  end

  test "unfeaturing redirects to index and informs user the topic is no longer featured" do
    topic = create(:topic, featured: false)
    post :unfeature, id: topic
    assert_redirected_to admin_topics_path
    assert_equal flash[:notice], "The topic #{topic.name} is no longer featured"
  end
end