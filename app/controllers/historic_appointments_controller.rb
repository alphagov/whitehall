class HistoricAppointmentsController < ApplicationController
  before_filter :load_role
  helper_method :previous_appointments

  def index
    @recent_appointments = previous_appointments.where('started_at > ?', DateTime.civil(1900)).collect {|r| RoleAppointmentPresenter.new(r) }
    @nineteenth_century_appointments = previous_appointments.between(DateTime.civil(1800), DateTime.civil(1900)).collect {|r| RoleAppointmentPresenter.new(r) }
    @eighteenth_century_appointments = previous_appointments.between(DateTime.civil(1700), DateTime.civil(1800)).collect {|r| RoleAppointmentPresenter.new(r) }
  end

  def show
    @person = PersonPresenter.new(Person.find(params[:person_id]))
    @role_appointment = RoleAppointmentPresenter.new(@person.role_appointments.for_role(@role).first)
    @historical_account = @role_appointment.historical_account
    raise(ActiveRecord::RecordNotFound, "Couldn't find HistoricalAccount for #{@person.inspect}  and #{@role.inspect}") unless @historical_account
  end

  private

  def load_role
    @role = Role.find(role_id)
    @role_title = params[:role].underscore.humanize.titleize.gsub('Past ', '')
  end

  def role_id
    Role::HISTORIC_ROLE_PARAM_MAPPINGS[params[:role]]
  end

  def previous_appointments
    @previous_appointments ||= @role.previous_appointments.includes(:role, :person).reorder('started_at DESC')
  end
end
