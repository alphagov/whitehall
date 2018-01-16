require 'test_helper'

class RolesPresenterTest < PresenterTestCase
  setup do
    @person_1 = stub_translatable_record(:person)
    @person_2 = stub_translatable_record(:person)

    @role_1 = stub_translatable_record(:role_without_organisations)
    @role_1.stubs(:current_person).returns(@person_1)

    @role_2 = stub_translatable_record(:role_without_organisations)
    @role_2.stubs(:current_person).returns(@person_1)

    @role_3 = stub_translatable_record(:role_without_organisations)
    @role_3.stubs(:current_person).returns(@person_2)

    @empty_role = stub_translatable_record(:role_without_organisations)
    @empty_role.stubs(:current_person).returns(nil)

    @presenter = RolesPresenter.new([@role_1, @role_2, @role_3, @empty_role], @view_context)
  end

  test "it decorates a collection of roles" do
    assert_equal [RolePresenter.new(@role_1),
                  RolePresenter.new(@role_2),
                  RolePresenter.new(@role_3),
                  RolePresenter.new(@empty_role)], @presenter.decorated_collection
  end

  test "it delegates array methods to the RolePresenter.new collection" do
    @presenter.expects(:from).with(3)
    @presenter.from(3)
  end

  test "it returns unique people" do
    assert_equal [@person_1, @person_2], @presenter.unique_people
  end

  test "it returns roles with unique people" do
    assert_equal [RolePresenter.new(@role_1), RolePresenter.new(@role_3)], @presenter.with_unique_people
  end

  test "#with_unique_people doesn't clober #unique_people" do
    @presenter.with_unique_people
    assert_equal [@person_1, @person_2], @presenter.unique_people
  end

  test "it returns the roles for a given person" do
    assert_equal [RolePresenter.new(@role_1), RolePresenter.new(@role_2)], @presenter.roles_for(@role_1.current_person)
  end

  test 'it can strip out roles that are not filled' do
    @presenter.remove_unfilled_roles!

    assert_equal [RolePresenter.new(@role_1),
                  RolePresenter.new(@role_2),
                  RolePresenter.new(@role_3)], @presenter.decorated_collection
  end

  test 'it can strip out roles that are not filled (even after looking at the collection)' do
    @presenter.decorated_collection
    @presenter.remove_unfilled_roles!

    assert_equal [RolePresenter.new(@role_1),
                  RolePresenter.new(@role_2),
                  RolePresenter.new(@role_3)], @presenter.decorated_collection
  end
end
