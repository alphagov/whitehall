require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase
  include PublicDocumentRoutesHelper

  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :policy
  should_allow_creating_of :policy
  should_allow_editing_of :policy
  should_allow_revision_of :policy

  should_allow_organisations_for :policy
  should_allow_ministerial_roles_for :policy
  should_allow_association_between_countries_and :policy
  should_allow_attached_images_for :policy
  should_not_use_lead_image_for :policy
  should_be_rejectable :policy
  should_be_publishable :policy
  should_be_force_publishable :policy
  should_be_able_to_delete_an_edition :policy
  should_link_to_public_version_when_published :policy
  should_not_link_to_public_version_when_not_published :policy
  should_prevent_modification_of_unmodifiable :policy

  test "show the 'add supporting page' button for an unpublished edition" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    assert_select "a[href='#{new_admin_document_supporting_page_path(draft_policy)}']"
  end

  test "don't show the 'add supporting page' button for a published policy" do
    published_policy = create(:published_policy)

    get :show, id: published_policy

    refute_select "a[href='#{new_admin_document_supporting_page_path(published_policy)}']"
  end

  test "show lists supporting pages when there are some" do
    draft_policy = create(:draft_policy)
    first_supporting_page = create(:supporting_page, edition: draft_policy)
    second_supporting_page = create(:supporting_page, edition: draft_policy)

    get :show, id: draft_policy

    assert_select ".supporting_pages" do
      assert_select_object(first_supporting_page) do
        assert_select "a[href='#{admin_supporting_page_path(first_supporting_page)}'] span.title", text: first_supporting_page.title
      end
      assert_select_object(second_supporting_page) do
        assert_select "a[href='#{admin_supporting_page_path(second_supporting_page)}'] span.title", text: second_supporting_page.title
      end
    end
  end

  test "doesn't show supporting pages list when empty" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    refute_select ".supporting_pages .supporting_page"
  end

  test "new should display policy topics field" do
    get :new

    assert_select "form#document_new" do
      assert_select "select[name*='document[policy_topic_ids]']"
    end
  end

  test "create should associate policy topics with policy" do
    first_policy_topic = create(:policy_topic)
    second_policy_topic = create(:policy_topic)
    attributes = attributes_for(:policy)

    post :create, document: attributes.merge(
      policy_topic_ids: [first_policy_topic.id, second_policy_topic.id]
    )

    assert policy = Policy.last
    assert_equal [first_policy_topic, second_policy_topic], policy.policy_topics
  end

  test "edit should display policy topics field" do
    policy = create(:policy)

    get :edit, id: policy

    assert_select "form#document_edit" do
      assert_select "select[name*='document[policy_topic_ids]']"
    end
  end

  test "update should associate policy topics with policy" do
    first_policy_topic = create(:policy_topic)
    second_policy_topic = create(:policy_topic)

    policy = create(:policy, policy_topics: [first_policy_topic])

    put :update, id: policy, document: {
      policy_topic_ids: [second_policy_topic.id]
    }

    policy.reload
    assert_equal [second_policy_topic], policy.policy_topics
  end

  test "update should remove all policy topics if none specified" do
    policy_topic = create(:policy_topic)

    policy = create(:policy, policy_topics: [policy_topic])

    put :update, id: policy, document: {}

    policy.reload
    assert_equal [], policy.policy_topics
  end

  test "updating should retain associations to related editions" do
    policy = create(:draft_policy)
    publication = create(:draft_publication, related_policies: [policy])
    assert policy.related_editions.include?(publication), "policy and publication should be related"

    put :update, id: policy, document: {title: "another title"}

    policy.reload
    assert policy.related_editions.include?(publication), "polcy and publication should still be related"
  end

  test "show does not display image for edition types that do not allow one" do
    policy = create(:policy)

    get :show, id: policy

    refute_select "article.document .image img"
  end
end
