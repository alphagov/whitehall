require 'test_helper'

class Admin::PolicyAreasControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  should_be_an_admin_controller

  test "new displays policy area form" do
    get :new

    assert_select "form#new_policy_area[action='#{admin_policy_areas_path}']" do
      assert_select "input[name='policy_area[name]'][type='text']"
      assert_select "textarea[name='policy_area[description]']"
      assert_select "input[type='submit']"
    end
  end

  test "new displays related policy areas field" do
    get :new

    assert_select "form#new_policy_area" do
      assert_select "select[name*='policy_area[related_policy_area_ids]']"
    end
  end

  test "create should create a new policy area" do
    attributes = attributes_for(:policy_area)

    post :create, policy_area: attributes

    assert policy_area = PolicyArea.last
    assert_equal attributes[:name], policy_area.name
    assert_equal attributes[:description], policy_area.description
  end

  test "create should associate policy areas with policy area" do
    first_policy_area = create(:policy_area)
    second_policy_area = create(:policy_area)
    attributes = attributes_for(:policy_area, name: "new-policy-area")

    post :create, policy_area: attributes.merge(
      related_policy_area_ids: [first_policy_area.id, second_policy_area.id]
    )

    assert policy_area = PolicyArea.find_by_name("new-policy-area")
    assert_equal [first_policy_area, second_policy_area].to_set, policy_area.related_policy_areas.to_set
  end

  test "creating a policy area without a name shows errors" do
    post :create, policy_area: { name: "", description: "description" }
    assert_select ".form-errors"
  end

  test "creating a policy area without a description shows errors" do
    post :create, policy_area: { name: "name", description: "" }
    assert_select ".form-errors"
  end

  test "index should show related policy areas" do
    policy_area_1 = create(:policy_area)
    policy_area_2 = create(:policy_area)
    policy_area = create(:policy_area, related_policy_areas: [policy_area_1, policy_area_2])

    get :index

    assert_select_object(policy_area) do
      assert_select ".related" do
        assert_select_object policy_area_1
        assert_select_object policy_area_2
      end
    end
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

  test "edit should display policy area fields" do
    policy_area = create(:policy_area)

    get :edit, id: policy_area

    form_id = "edit_#{dom_id(policy_area)}"
    assert_select "form##{form_id}[action='#{admin_policy_area_path(policy_area)}']" do
      assert_select "input[name='policy_area[name]'][type='text']"
      assert_select "textarea[name='policy_area[description]']"
      assert_select "input[type='submit']"
    end
  end

  test "edit should display related policy areas field with selections" do
    policy_area_1 = create(:policy_area, name: "related-policy-area-1")
    policy_area_2 = create(:policy_area, name: "related-policy-area-2")
    policy_area = create(:policy_area, related_policy_areas: [policy_area_1, policy_area_2])

    get :edit, id: policy_area

    form_id = "edit_#{dom_id(policy_area)}"
    assert_select "form##{form_id}" do
      assert_select "select[name*='policy_area[related_policy_area_ids]']" do
        assert_select "option[selected='selected']", text: "related-policy-area-1"
        assert_select "option[selected='selected']", text: "related-policy-area-2"
      end
    end
  end

  test "edit should include all policy areas except edited policy area in related policy area options" do
    policy_area_1 = create(:policy_area, name: "policy-area-1")
    policy_area_2 = create(:policy_area, name: "policy-area-2")
    policy_area = create(:policy_area, name: "policy-area-for-editing")

    get :edit, id: policy_area

    form_id = "edit_#{dom_id(policy_area)}"
    assert_select "form##{form_id}" do
      assert_select "select[name*='policy_area[related_policy_area_ids]']" do
        assert_select "option", text: "policy-area-1"
        assert_select "option", text: "policy-area-2"
        assert_select "option", text: "policy-area-for-editing", count: 0
      end
    end
  end

  test "updating should save modified policy area attributes" do
    policy_area = create(:policy_area)

    put :update, id: policy_area, policy_area: {
      name: "new-name",
      description: "new-description"
    }

    policy_area.reload
    assert_equal "new-name", policy_area.name
    assert_equal "new-description", policy_area.description
  end

  test "update should associate related policy areas with policy area" do
    first_policy_area = create(:policy_area)
    second_policy_area = create(:policy_area)

    policy_area = create(:policy_area, related_policy_areas: [first_policy_area])

    put :update, id: policy_area, policy_area: {
      related_policy_area_ids: [second_policy_area.id]
    }

    policy_area.reload
    assert_equal [second_policy_area], policy_area.related_policy_areas
  end

  test "update should remove all related policy areas if none specified" do
    first_policy_area = create(:policy_area)
    second_policy_area = create(:policy_area)

    policy_area = create(:policy_area,
      related_policy_area_ids: [first_policy_area.id, second_policy_area.id]
    )

    put :update, id: policy_area, policy_area: {}

    policy_area.reload
    assert_equal [], policy_area.related_policy_areas
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
    published_association = policy_area.policy_area_memberships.where(policy_id: policy.id).first
    draft_association = policy_area.policy_area_memberships.where(policy_id: draft_policy.id).first

    get :edit, id: policy_area.id

    assert_select "#policy_order input[type=hidden][value=#{published_association.id}]"
    refute_select "#policy_order input[type=hidden][value=#{draft_association.id}]"
  end

  test "allows updating of document ordering" do
    policy_area = create(:policy_area)
    policy = create(:policy, policy_areas: [policy_area])
    association = policy_area.policy_area_memberships.first

    put :update, id: policy_area.id, policy_area: {name: "Blah", description: "Blah", policy_area_memberships_attributes: {
      "0" => {id: association.id, ordering: "4"}
    }}

    assert_equal 4, association.reload.ordering
  end

  test "should be able to destroy a destroyable policy area" do
    policy_area = create(:policy_area)
    delete :destroy, id: policy_area.id

    assert_response :redirect
    assert_equal "Policy area destroyed", flash[:notice]
    assert policy_area.reload.deleted?
  end

  test "should indicate that a document is not destroyable when editing" do
    policy_area_with_published_policy = create(:policy_area, policies: [build(:published_policy, title: "thingies")])

    get :edit, id: policy_area_with_published_policy.id
    assert_select ".documents_preventing_destruction" do
      assert_select "a", "thingies"
      assert_select ".document_state", "(published policy)"
    end
  end

  test "destroying a policy area which has associated content" do
    policy_area_with_published_policy = create(:policy_area, policies: [build(:published_policy)])

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