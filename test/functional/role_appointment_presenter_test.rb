require 'test_helper'

class RoleAppointmentPresenterTest < PresenterTestCase
  setup do
    @appointment = stub_record(:role_appointment)
    @presenter = RoleAppointmentPresenter.decorate(@appointment)
  end

  test 'url is the ministerial_role_url of the appointed role if role is ministerial' do
    @appointment.role.stubs(:ministerial?).returns(true)
    assert_equal ministerial_role_url(@appointment.role), @presenter.url
  end

  test 'url is nil if appointed role is not ministerial' do
    @appointment.role.stubs(:ministerial?).returns(false)
    assert_nil @presenter.url
  end

  test 'link links role name to role url if url available' do
    @presenter.stubs(:url).returns('http://example.com/ministers/minister-of-funk')
    @appointment.role.stubs(:name).returns('The Minister of Funk')
    assert_select_from @presenter.link, 'a[href="http://example.com/ministers/minister-of-funk"]', text: 'The Minister of Funk'
  end

  test 'link returns just name if url unavailable' do
    @presenter.stubs(:url).returns(nil)
    @appointment.role.stubs(:name).returns('The Minister of Funk')
    assert_equal 'The Minister of Funk', @presenter.link
  end
end