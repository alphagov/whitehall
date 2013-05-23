require 'test_helper'

class Admin::PoliciesControllerTest < ActionController::TestCase
  include PublicDocumentRoutesHelper

  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :policy
  should_allow_editing_of :policy

  should_allow_organisations_for :policy
  should_allow_ministerial_roles_for :policy
  should_allow_association_between_world_locations_and :policy
  should_allow_association_with_topics :policy
  should_allow_attached_images_for :policy
  should_prevent_modification_of_unmodifiable :policy
  should_allow_alternative_format_provider_for :policy
  should_allow_scheduled_publication_of :policy
  should_allow_access_limiting_of :policy
  should_allow_relevance_to_local_government_of :policy

  view_test "show the 'add supporting page' button for an unpublished edition" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    assert_select "a[href='#{new_admin_edition_supporting_page_path(draft_policy)}']"
  end

  view_test "do not show the 'add supporting page' button for a published policy" do
    published_policy = create(:published_policy)

    get :show, id: published_policy

    refute_select "a[href='#{new_admin_edition_supporting_page_path(published_policy)}']"
  end

  view_test "show lists supporting pages when there are some" do
    draft_policy = create(:draft_policy)
    first_supporting_page = create(:supporting_page, edition: draft_policy)
    second_supporting_page = create(:supporting_page, edition: draft_policy)

    get :show, id: draft_policy

    assert_select ".supporting_pages" do
      assert_select_object(first_supporting_page) do
        assert_select "a[href='#{admin_supporting_page_path(first_supporting_page)}']", text: first_supporting_page.title
      end
      assert_select_object(second_supporting_page) do
        assert_select "a[href='#{admin_supporting_page_path(second_supporting_page)}']", text: second_supporting_page.title
      end
    end
  end

  view_test "does not show supporting pages list when empty" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    refute_select ".supporting_pages .supporting_page"
  end

  view_test "show displays the policy team responsible for this policy" do
    policy_team = create(:policy_team, name: 'policy-team', email: 'policy-team@example.com')
    draft_policy = create(:draft_policy, policy_teams: [policy_team])

    get :show, id: draft_policy

    assert_select policy_team_selector do
      assert_select '.name', text: 'policy-team'
      assert_select 'a', text: 'policy-team@example.com'
    end
  end

  view_test "show does not display the policy team section if no policy team is associated with the policy" do
    draft_policy = create(:draft_policy)

    get :show, id: draft_policy

    refute_select policy_team_selector
  end

  view_test "new should display policy team field" do
    get :new

    assert_select "form#new_edition" do
      assert_select "select[name='edition[policy_team_ids]']"
    end
  end

  test "updating should retain associations to related editions" do
    policy = create(:draft_policy)
    publication = create(:draft_publication, related_editions: [policy])
    assert policy.related_editions.include?(publication), "policy and publication should be related"

    put :update, id: policy, edition: controller_attributes_for_instance(policy, title: "another title")

    policy.reload
    assert policy.related_editions.include?(publication), "polcy and publication should still be related"
  end

  view_test "show does not display image for edition types that do not allow one" do
    policy = create(:policy)

    get :show, id: policy

    refute_select "article.document .image img"
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
