require 'test_helper'

class RoleAppointmentPresenterTest < PresenterTestCase
  setup do
    @appointment = stub_record(:role_appointment, role: stub_record(:role), person: stub_record(:person))
    @presenter = RoleAppointmentPresenter.decorate(@appointment)
  end

  test 'role decorates appointment#role with a RolePresenter' do
    assert @presenter.role.is_a? RolePresenter
    assert_same @presenter.role.model, @appointment.role
  end

  test 'link delegates to role#link' do
    @presenter.role.stubs(:link).returns(:link_from_role)
    assert_equal :link_from_role, @presenter.link
  end
end