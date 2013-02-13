require 'test_helper'

class WorldwideOfficeAppointmentPresenterTest < PresenterTestCase
  setup do
    @appointment = stub_record(:worldwide_office_appointment,
                                person: stub_record(:person),
                                worldwide_office: stub_record(:worldwide_office))
    @presenter = WorldwideOfficeAppointmentPresenter.decorate(@appointment)
  end

  test "does not have a path" do
    assert_nil @presenter.path
  end

  test "link returns the job title" do
    assert_equal @appointment.job_title, @presenter.link
  end

  test 'current_person returns a PersonPresenter for the appointee' do
    assert_equal @presenter.current_person, PersonPresenter.new(@appointment.person)
  end
end
