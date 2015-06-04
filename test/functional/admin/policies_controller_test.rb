require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  view_test "show the 'add supporting page' button for an unpublished edition" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    assert_select "a[href='#{admin_new_policy_supporting_page_path(draft_policy)}']"
  end

  view_test "show the 'add supporting page' button for a published policy" do
    published_policy = create(:published_policy)

    get :show, id: published_policy

    assert_select "a[href='#{admin_new_policy_supporting_page_path(published_policy)}']"
  end

  view_test "show lists supporting pages when there are some" do
    draft_policy = create(:draft_policy)
    first_supporting_page = create(:supporting_page, related_policies: [draft_policy])
    second_supporting_page = create(:supporting_page, related_policies: [draft_policy])

    get :show, id: draft_policy

    assert_select "a[href='#{admin_supporting_page_path(first_supporting_page)}']", text: first_supporting_page.title
    assert_select "a[href='#{admin_supporting_page_path(second_supporting_page)}']", text: second_supporting_page.title
  end

  view_test "does not show supporting pages list when empty" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    refute_select ".supporting_pages .supporting_page"
  end

  view_test "show does not display the group section if no group is associated with the policy" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    refute_select policy_group_selector
  end

  view_test "show does not display image for edition types that do not allow one" do
    policy = create(:policy)

    get :show, id: policy

    refute_select "article.document .image img"
  end

  view_test "topics returns list of the policy's topics when JSON requested" do
    topics = [create(:topic), create(:topic)]
    policy_content_id = 'asfd-asdf-asdf-asdf'
    create(:classification_policy, policy_content_id: policy_content_id, classification: topics.first)
    create(:classification_policy, policy_content_id: policy_content_id, classification: topics.second)

    get :topics, policy_id: policy_content_id, format: :json
    assert_equal topics.first.id, json_response['topics'].first
    assert_equal topics.second.id, json_response['topics'].second
  end

  view_test "allows policy editing for GDS admins" do
    policy = create(:draft_policy)

    login_as :gds_editor
    get :edit, id: policy
    assert_response 302

    login_as :gds_admin
    get :edit, id: policy
    assert_response :success
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
