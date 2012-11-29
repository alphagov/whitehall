require 'test_helper'

class Admin::GroupsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "index should display a list of groups" do
    organisation_one = create(:organisation, name: "organisation-one")
    organisation_two = create(:organisation, name: "organisation-two")
    group_one = create(:group, name: "group-one", organisation: organisation_one)
    group_two = create(:group, name: "group-two", organisation: organisation_two)

    get :index

    assert_select ".groups" do
      assert_select_object group_one do
        assert_select ".name", "group-one"
        assert_select ".organisation", "organisation-one"
      end
      assert_select_object group_two do
        assert_select ".name", "group-two"
        assert_select ".organisation", "organisation-two"
      end
    end
  end

  test "index should order group by organisation name versus role name" do
    org_A = create(:organisation, name: "A")
    org_C = create(:organisation, name: "C")
    org_B = create(:organisation, name: "B")
    group_A = create(:group, name: "name", organisation: org_A)
    group_C = create(:group, name: "name", organisation: org_C)
    group_B = create(:group, name: "name", organisation: org_B)

    get :index

    assert_equal [group_A, group_B, group_C], assigns(:groups)
  end

  test "index should order groups by name all other things being equal" do
    org = create(:organisation)
    group_A = create(:group, name: "A", organisation: org)
    group_C = create(:group, name: "C", organisation: org)
    group_B = create(:group, name: "B", organisation: org)

    get :index

    assert_equal [group_A, group_B, group_C], assigns(:groups)
  end

  test "index should display a link to create a new group" do
    get :index

    assert_select ".actions" do
      assert_select "a[href='#{new_admin_group_path}']"
    end
  end

  test "index should display links to edit an existing group" do
    group_one = create(:group)
    group_two = create(:group)

    get :index

    assert_select_object group_one do
      assert_select "a[href='#{edit_admin_group_path(group_one)}']"
    end
    assert_select_object group_two do
      assert_select "a[href='#{edit_admin_group_path(group_two)}']"
    end
  end

  test "provides delete buttons for groups" do
    group = create(:group)

    get :index

    assert_select_object group do
      assert_select ".delete form[action='#{admin_group_path(group)}']" do
        assert_select "input[name='_method'][value='delete']"
        assert_select "input[type='submit']"
      end
    end
  end

  test "new should display form for creating a new group" do
    get :new

    assert_select "form[action='#{admin_groups_path}']" do
      assert_select "input[name='group[name]'][type='text']"
      assert_select "select[name*='group[organisation_id]']"
      assert_select "input[type='submit']"
    end
  end

  test "create should create a new group" do
    organisation = create(:organisation)

    post :create, group: attributes_for(:group,
      name: "group-name",
      organisation_id: organisation.id
    )

    assert group = Group.last
    assert_equal "group-name", group.name
    assert_equal organisation, group.organisation
  end

  test "create redirects to the index on success" do
    organisation = create(:organisation)

    post :create, group: attributes_for(:group, organisation_id: organisation.id)

    assert_redirected_to admin_groups_path
  end

  test "create should inform the user when a group is created successfully" do
    organisation = create(:organisation)

    post :create, group: attributes_for(:group, name: "group-name", organisation_id: organisation.id)

    assert_equal %{"group-name" created.}, flash[:notice]
  end

  test "create with invalid data should display errors" do
    post :create, group: attributes_for(:group, name: nil)

    assert_select ".form-errors"
  end

  test "edit should display form for updating an existing group" do
    organisation = create(:organisation, name: "org-name")
    group = create(:group, name: "group-name", organisation: organisation)

    get :edit, id: group

    assert_select "form[action='#{admin_group_path(group)}']" do
      assert_select "input[name='group[name]'][value='group-name']"
      assert_select "select[name*='group[organisation_id]']" do
        assert_select "option[selected='selected']", text: "org-name"
      end
      assert_select "input[type='submit']"
    end
  end

  test "update should modify existing group" do
    org_one, org_two = create(:organisation), create(:organisation)
    group = create(:group, name: "group-name", organisation: org_one)

    put :update, id: group, group: {
      name: "new-name",
      organisation_id: org_two.id
    }

    group = Group.find(group.id)
    assert_equal "new-name", group.name
    assert_equal org_two, group.organisation
  end

  test "update redirects to the index on success" do
    group = create(:group)

    put :update, id: group, group: attributes_for(:group)

    assert_redirected_to admin_groups_path
  end

  test "update should inform the user when a group is updated successfully" do
    group = create(:group)

    put :update, id: group, group: attributes_for(:group, name: "group-name")

    assert_equal %{"group-name" updated.}, flash[:notice]
  end

  test "update with invalid data should display errors" do
    group = create(:group)

    put :update, id: group, group: attributes_for(:group, name: nil)

    assert_select ".form-errors"
  end

  test "should be able to destroy a destroyable group" do
    group = create(:group, name: "Prime Minister")

    delete :destroy, id: group

    assert_redirected_to admin_groups_path
    refute Group.find_by_id(group.id)
    assert_equal %{"Prime Minister" destroyed.}, flash[:notice]
  end
end
