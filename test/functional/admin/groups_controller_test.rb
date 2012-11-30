require 'test_helper'

class Admin::GroupsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @organisation = create(:organisation)
  end

  should_be_an_admin_controller

  test "new should display form for creating a new group" do
    get :new, organisation_id: @organisation.id

    assert_select "form[action='#{admin_organisation_groups_path(@organisation)}']" do
      assert_select "input[name='group[name]'][type='text']"
      assert_select "input[type='submit']"
    end
  end

  test "new should display 5 sets of fields for adding a new member of the group" do
    get :new, organisation_id: @organisation.id

    assert_select "form#new_group" do
      (0..4).each do |index|
        assert_select "select[name='group[group_memberships_attributes][#{index}][person_id]']"
      end
    end
  end

  test "create should create a new group" do
    post :create, organisation_id: @organisation.id, group: attributes_for(:group,
      name: "group-name"
    )

    assert group = Group.last
    assert_equal "group-name", group.name
    assert_equal @organisation, group.organisation
  end

  test "create redirects to the organisation page groups tab on success" do
    post :create, organisation_id: @organisation.id, group: attributes_for(:group)

    assert_redirected_to admin_organisation_path(@organisation, anchor: "groups")
  end

  test "create should inform the user when a group is created successfully" do
    post :create, organisation_id: @organisation.id, group: attributes_for(:group,
      name: "group-name"
    )

    assert_equal %{"group-name" created.}, flash[:notice]
  end

  test "create with invalid data should display errors" do
    post :create, organisation_id: @organisation.id, group: attributes_for(:group,
      name: nil
    )

    assert_select ".form-errors"
  end

  test "edit should display form for updating an existing group" do
    group = create(:group, name: "group-name", organisation: @organisation)

    get :edit, organisation_id: @organisation.id, id: group

    assert_select "form[action='#{admin_organisation_group_path(@organisation, group)}']" do
      assert_select "input[name='group[name]'][value='group-name']"
      assert_select "input[type='submit']"
    end
  end

  test "edit should display fields for editing or deleting an existing member of an existing group" do
    person = create(:person)
    group = create(:group, name: "group-name", organisation: @organisation, members: [person])

    get :edit, organisation_id: @organisation.id, id: group

    assert_select "form#edit_#{dom_id(group)}" do
      assert_select "input[type='hidden'][name='group[group_memberships_attributes][0][id]'][value=?]", group.group_memberships.first.id
      assert_select "select[name='group[group_memberships_attributes][0][person_id]']" do
        assert_select "option[selected='selected'][value=?]", person.id
      end
      assert_select "input[type='checkbox'][name='group[group_memberships_attributes][0][_destroy]'][value=1]"
    end
  end

  test "edit should display 5 sets of fields for adding a new member of an existing group" do
    group = create(:group, name: "group-name", organisation: @organisation)

    get :edit, organisation_id: @organisation.id, id: group

    assert_select "form#edit_#{dom_id(group)}" do
      (0..4).each do |index|
        assert_select "select[name='group[group_memberships_attributes][#{index}][person_id]']"
      end
    end
  end

  test "update should modify existing group" do
    group = create(:group, name: "group-name", organisation: @organisation)

    put :update, organisation_id: @organisation.id, id: group, group: {
      name: "new-name"
    }

    group = Group.find(group.id)
    assert_equal "new-name", group.name
  end

  test "update redirects to the organisation page groups tab on success" do
    group = create(:group)

    put :update, organisation_id: @organisation.id, id: group, group: attributes_for(:group)

    assert_redirected_to admin_organisation_path(@organisation, anchor: "groups")
  end

  test "update should inform the user when a group is updated successfully" do
    group = create(:group)

    put :update, organisation_id: @organisation.id, id: group, group: attributes_for(:group, name: "group-name")

    assert_equal %{"group-name" updated.}, flash[:notice]
  end

  test "update with invalid data should display errors" do
    group = create(:group)

    put :update, organisation_id: @organisation.id, id: group, group: attributes_for(:group, 
      name: nil
    )

    assert_select ".form-errors"
  end

  test "should be able to destroy a destroyable group" do
    group = create(:group, name: "Prime Minister")

    delete :destroy, organisation_id: @organisation.id, id: group

    assert_redirected_to admin_organisation_path(@organisation, anchor: "groups")
    refute Group.find_by_id(group.id)
    assert_equal %{"Prime Minister" destroyed.}, flash[:notice]
  end

  test "should not be able to destroy an indestructible group" do
    group = create(:group, name: "Prime Minister", members: [create(:person)])

    delete :destroy, organisation_id: @organisation.id, id: group

    assert_redirected_to admin_organisation_path(@organisation, anchor: "groups")
    assert Group.find_by_id(group.id)
    assert_equal %{Cannot destroy a group with members.}, flash[:alert]
  end
end
