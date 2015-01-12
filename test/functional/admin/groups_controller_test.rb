require 'test_helper'

class Admin::GroupsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @organisation = create(:organisation)
  end

  should_be_an_admin_controller

  view_test "new should display form for creating a new group" do
    get :new, organisation_id: @organisation.id

    assert_select "form[action='#{admin_organisation_groups_path(@organisation)}']" do
      assert_select "input[name='group[name]'][type='text']"
      assert_select "textarea[name='group[description]']"
      assert_select "input[type='submit']"
    end
  end

  view_test "new should display 5 sets of fields for adding a new member of the group" do
    get :new, organisation_id: @organisation.id

    assert_select "form#new_group" do
      (0..4).each do |index|
        assert_select "select[name='group[group_memberships_attributes][#{index}][person_id]']"
      end
    end
  end

  test "create should create a new group with new members ignoring blank members" do
    person_one, person_two = create(:person), create(:person)

    post :create, organisation_id: @organisation.id, group: attributes_for(:group,
      name: "group-name",
      description: "group-description",
      group_memberships_attributes: {
        "0" => { person_id: person_one.id },
        "1" => { person_id: person_two.id },
        "2" => { person_id: "" }
      }
    )

    assert group = Group.last
    assert_equal "group-name", group.name
    assert_equal "group-description", group.description
    assert_equal @organisation, group.organisation
    assert_equal [person_one, person_two], group.group_memberships.map(&:person)
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

  view_test "create with invalid data should display errors" do
    post :create, organisation_id: @organisation.id, group: attributes_for(:group,
      name: nil
    )

    assert_select ".form-errors"
  end

  view_test "create should not allow the same person to be added to the same group" do
    person = create(:person)

    post :create, organisation_id: @organisation.id, group: attributes_for(:group,
      name: "group-name",
      group_memberships_attributes: {
        "0" => { person_id: person.id },
        "1" => { person_id: person.id }
      }
    )

    assert_select ".form-errors", /The same person has been added more than once/
  end

  view_test "edit should display form for updating an existing group" do
    group = create(:group, name: "group-name", description: "group-description", organisation: @organisation)

    get :edit, organisation_id: @organisation.id, id: group

    assert_select "form[action='#{admin_organisation_group_path(@organisation, group)}']" do
      assert_select "input[name='group[name]'][value='group-name']"
      assert_select "textarea[name='group[description]']", "group-description"
      assert_select "input[type='submit']"
    end
  end

  view_test "edit should display fields for editing or deleting an existing member of an existing group" do
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

  view_test "edit should display 5 sets of fields for adding a new member of an existing group" do
    group = create(:group, name: "group-name", organisation: @organisation)

    get :edit, organisation_id: @organisation.id, id: group

    assert_select "form#edit_#{dom_id(group)}" do
      (0..4).each do |index|
        assert_select "select[name='group[group_memberships_attributes][#{index}][person_id]']"
      end
    end
  end

  test "update should modify existing group" do
    group = create(:group, name: "group-name", description: "group-description", organisation: @organisation)

    put :update, organisation_id: @organisation.id, id: group, group: {
      name: "new-name",
      description: "new-description"
    }

    group.reload
    assert_equal "new-name", group.name
    assert_equal "new-description", group.description
  end

  test "update should add a new member" do
    person = create(:person)
    group = create(:group, name: "group-name", organisation: @organisation)

    put :update, organisation_id: @organisation.id, id: group, group: {
      group_memberships_attributes: {
        "0" => { person_id: person.id }
      }
    }

    assert_equal [person], group.members(reload = true)
  end

  test "update should update a member" do
    person_one, person_two = create(:person), create(:person)
    group = create(:group, name: "group-name", organisation: @organisation)
    membership_one = create(:group_membership, group: group, person: person_one)

    put :update, organisation_id: @organisation.id, id: group, group: {
      group_memberships_attributes: {
        "0" => { id: membership_one.id, person_id: person_two.id, _destroy: 0 }
      }
    }

    assert_equal [person_two], group.members(reload = true)
  end

  test "update should delete a member" do
    person = create(:person)
    group = create(:group, name: "group-name", organisation: @organisation)
    membership = create(:group_membership, group: group, person: person)

    put :update, organisation_id: @organisation.id, id: group, group: {
      group_memberships_attributes: {
        "0" => { id: membership.id, person_id: person.id, _destroy: 1 }
      }
    }

    assert_equal [], group.members(reload = true)
  end

  test "update should ignore new blank members" do
    group = create(:group, name: "group-name", organisation: @organisation)

    put :update, organisation_id: @organisation.id, id: group, group: {
      group_memberships_attributes: {
        "0" => { person_id: "" }
      }
    }

    group.reload
    assert_equal [], group.group_memberships.map(&:person)
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

  view_test "update with invalid data should display errors" do
    group = create(:group)

    put :update, organisation_id: @organisation.id, id: group, group: attributes_for(:group,
      name: nil
    )

    assert_select ".form-errors"
  end

  view_test "update should not allow the same person to be added to the same group" do
    group, person = create(:group), create(:person)
    membership = create(:group_membership, group: group, person: person)

    put :update, organisation_id: @organisation.id, id: group, group: attributes_for(:group,
      group_memberships_attributes: {
        "0" => { id: membership.id, person_id: person.id, _destroy: 0 },
        "1" => { person_id: person.id }
      }
    )

    assert_select ".form-errors", /The same person has been added more than once/
  end

  test "should be able to destroy a destroyable group" do
    group = create(:group, name: "Prime Minister")

    delete :destroy, organisation_id: @organisation.id, id: group

    assert_redirected_to admin_organisation_path(@organisation, anchor: "groups")
    refute Group.find_by(id: group.id)
    assert_equal %{"Prime Minister" destroyed.}, flash[:notice]
  end

  test "should not be able to destroy an indestructible group" do
    group = create(:group, name: "Prime Minister", members: [create(:person)])

    delete :destroy, organisation_id: @organisation.id, id: group

    assert_redirected_to admin_organisation_path(@organisation, anchor: "groups")
    assert Group.find_by(id: group.id)
    assert_equal %{Cannot destroy a group with members.}, flash[:alert]
  end
end
