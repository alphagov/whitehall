require 'test_helper'

class RolesPresenterTest < PresenterTestCase
  setup do
    @person1 = stub_translatable_record(:person)
    @person2 = stub_translatable_record(:person)

    @role1 = stub_translatable_record(:role_without_organisations)
    @role1.stubs(:current_person).returns(@person1)

    @role2 = stub_translatable_record(:role_without_organisations)
    @role2.stubs(:current_person).returns(@person1)

    @role3 = stub_translatable_record(:role_without_organisations)
    @role3.stubs(:current_person).returns(@person2)

    @empty_role = stub_translatable_record(:role_without_organisations)
    @empty_role.stubs(:current_person).returns(nil)

    @presenter = RolesPresenter.new([@role1, @role2, @role3, @empty_role], @view_context)
  end

  test "it decorates a collection of roles" do
    assert_equal [  RolePresenter.new(@role1),
                    RolePresenter.new(@role2),
                    RolePresenter.new(@role3),
                    RolePresenter.new(@empty_role)], @presenter.decorated_collection
  end

  test "it delegates array methods to the RolePresenter.new collection" do
    @presenter.expects(:from).with(3)
    @presenter.from(3)
  end

  test "it returns unique people" do
    assert_equal [@person1, @person2], @presenter.unique_people
  end

  test "it returns roles with unique people" do
    assert_equal [RolePresenter.new(@role1), RolePresenter.new(@role3)], @presenter.with_unique_people
  end

  test "#with_unique_people doesn't clober #unique_people" do
    @presenter.with_unique_people
    assert_equal [@person1, @person2], @presenter.unique_people
  end

  test "it returns the roles for a given person" do
    assert_equal [RolePresenter.new(@role1), RolePresenter.new(@role2)], @presenter.roles_for(@role1.current_person)
  end

  test 'it can strip out roles that are not filled' do
    @presenter.remove_unfilled_roles!

    assert_equal [ RolePresenter.new(@role1),
                   RolePresenter.new(@role2),
                   RolePresenter.new(@role3) ], @presenter.decorated_collection
  end

  test 'it can strip out roles that are not filled (even after looking at the collection)' do
    @presenter.decorated_collection
    @presenter.remove_unfilled_roles!

    assert_equal [ RolePresenter.new(@role1),
                   RolePresenter.new(@role2),
                   RolePresenter.new(@role3) ], @presenter.decorated_collection
  end
end
