require 'test_helper'

class Admin::PolicyAreasControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test_controller_is_a Admin::BaseController

  test "creating a policy area without a name shows errors" do
    post :create, policy_area: { name: "", description: "description" }
    assert_select ".form-errors"
  end

  test "creating a policy area without a description shows errors" do
    post :create, policy_area: { name: "name", description: "" }
    assert_select ".form-errors"
  end

  test "indexing shows a feature or unfeature button for policy areas" do
    featured_policy_area = create(:policy_area, featured: true)
    unfeatured_policy_area = create(:policy_area, featured: false)
    get :index

    assert_select_object featured_policy_area do
      assert_select "form[action='#{unfeature_admin_policy_area_path(featured_policy_area)}']" do
        assert_select "input[type='submit'][value='No Longer Feature']"
      end
      refute_select "form[action='#{feature_admin_policy_area_path(featured_policy_area)}']"
    end

    assert_select_object unfeatured_policy_area do
      assert_select "form[action='#{feature_admin_policy_area_path(unfeatured_policy_area)}']" do
        assert_select "input[type='submit'][value='Feature Policy Area']"
      end
      refute_select "form[action='#{unfeature_admin_policy_area_path(unfeatured_policy_area)}']"
    end
  end

  test "updating without a description shows errors" do
    policy_area = create(:policy_area)
    put :update, id: policy_area.id, policy_area: {name: "Blah", description: ""}

    assert_select ".form-errors"
  end

  test "editing only shows published documents for ordering" do
    policy_area = create(:policy_area)
    policy = create(:published_policy, policy_areas: [policy_area])
    draft_policy = create(:draft_policy, policy_areas: [policy_area])
    published_association = policy_area.document_policy_areas.where(document_id: policy.id).first
    draft_association = policy_area.document_policy_areas.where(document_id: draft_policy.id).first

    get :edit, id: policy_area.id

    assert_select "#policy_order input[type=hidden][value=#{published_association.id}]"
    refute_select "#policy_order input[type=hidden][value=#{draft_association.id}]"
  end

  test "allows updating of document ordering" do
    policy_area = create(:policy_area)
    policy = create(:policy, policy_areas: [policy_area])
    association = policy_area.document_policy_areas.first

    put :update, id: policy_area.id, policy_area: {name: "Blah", description: "Blah", document_policy_areas_attributes: {
      "0" => {id: association.id, ordering: "4"}
    }}

    assert_equal 4, association.reload.ordering
  end

  test "should be able to destroy a destroyable policy area" do
    policy_area = create(:policy_area)
    delete :destroy, id: policy_area.id

    assert_response :redirect
    assert_equal "Policy area destroyed", flash[:notice]
  end

  test "should indicate that a document is not destroyable when editing" do
    policy_area_with_published_policy = create(:policy_area, documents: [build(:published_policy, title: "thingies")])

    get :edit, id: policy_area_with_published_policy.id
    assert_select ".documents_preventing_destruction" do
      assert_select "a", "thingies"
      assert_select ".document_state", "(published policy)"
    end
  end

  test "destroying a policy area which has associated content" do
    policy_area_with_published_policy = create(:policy_area, documents: [build(:published_policy)])

    delete :destroy, id: policy_area_with_published_policy.id
    assert_equal "Cannot destroy policy area with associated content", flash[:alert]
  end

  test "featuring sets policy area featured flag" do
    policy_area = create(:policy_area, featured: false)
    post :feature, id: policy_area
    assert policy_area.reload.featured?
  end

  test "featuring redirects to index and informs user the policy area is now featured" do
    policy_area = create(:policy_area, featured: false)
    post :feature, id: policy_area
    assert_redirected_to admin_policy_areas_path
    assert_equal flash[:notice], "The policy area #{policy_area.name} is now featured"
  end

  test "unfeaturing unsets policy area featured flag" do
    policy_area = create(:policy_area, featured: true)
    post :unfeature, id: policy_area
    refute policy_area.reload.featured?
  end

  test "unfeaturing redirects to index and informs user the policy area is no longer featured" do
    policy_area = create(:policy_area, featured: false)
    post :unfeature, id: policy_area
    assert_redirected_to admin_policy_areas_path
    assert_equal flash[:notice], "The policy area #{policy_area.name} is no longer featured"
  end
end