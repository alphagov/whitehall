require 'test_helper'

class RoleAppointmentPresenterTest < PresenterTestCase
  setup do
    role = stub_translatable_record(:role_without_organisations)
    @appointment = stub_record(:role_appointment, role: role, person: stub_translatable_record(:person))
    @presenter = RoleAppointmentPresenter.new(@appointment, @view_context)
  end

  test 'role decorates appointment#role with a RolePresenter' do
    assert @presenter.role.is_a? RolePresenter
    assert_same @presenter.role.model, @appointment.role
  end

  test 'role_link delegates to role#link' do
    @presenter.role.stubs(:link).returns(:link_from_role)
    assert_equal :link_from_role, @presenter.role_link
  end
end