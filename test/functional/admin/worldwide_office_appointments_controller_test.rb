# encoding: utf-8
require 'test_helper'

class Admin::WorldwideOfficeAppointmentsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
    @office = create(:worldwide_office)
  end

  test "get new" do
    get :new, worldwide_office_id: @office.to_param

    assert_response :success
    assert_template :new
    assert_equal @office, assigns(:worldwide_office)
    assert assigns(:worldwide_office_appointment).is_a?(WorldwideOfficeAppointment)
    assert assigns(:worldwide_office_appointment).new_record?
  end

  test "creating an appointment" do
    person = create(:person)
    post :create, worldwide_office_id: @office.to_param, worldwide_office_appointment: { person_id: person.id, job_title: 'Defence Attaché'}

    refute_nil appointment = @office.worldwide_office_appointments.last
    assert_equal 'Defence Attaché', appointment.job_title
    assert_equal person, appointment.person
    assert_equal 'Appointment created', flash[:notice]
    assert_redirected_to [:appointments, :admin, @office]
  end

  test "get edit" do
    appointment = create(:worldwide_office_appointment, worldwide_office: @office)
    get :edit, id: appointment.to_param, worldwide_office_id: @office.to_param

    assert_response :success
    assert_template :edit
    assert_equal @office, assigns(:worldwide_office)
    assert_equal appointment, assigns(:worldwide_office_appointment)
  end

  test "updating an appointment" do
    appointment = create(:worldwide_office_appointment, worldwide_office: @office, job_title: 'Defence Attache')
    put :update, id: appointment.to_param, worldwide_office_id: @office.to_param, worldwide_office_appointment: { job_title: 'Defence Attaché' }

    assert_equal 'Defence Attaché', appointment.reload.job_title
    assert_equal 'Appointment updated', flash[:notice]
    assert_redirected_to [:appointments, :admin, @office]
  end

  test "destroying an appointment" do
    appointment = create(:worldwide_office_appointment, worldwide_office: @office)
    delete :destroy, id: appointment.to_param, worldwide_office_id: @office.to_param

    refute WorldwideOfficeAppointment.exists?(appointment)
    assert_equal 'Appointment deleted', flash[:notice]
    assert_redirected_to [:appointments, :admin, @office]
  end
end
