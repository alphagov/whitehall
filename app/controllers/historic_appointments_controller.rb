class HistoricAppointmentsController < PublicFacingController
  before_filter :load_role, except: [:past_chancellors]
  helper_method :previous_appointments_with_unique_people

  def index
    @recent_appointments = previous_appointments.where('started_at > ?', DateTime.civil(1900)).map { |r| RoleAppointmentPresenter.new(r, view_context) }
    @nineteenth_century_appointments = previous_appointments.between(DateTime.civil(1800), DateTime.civil(1900)).map { |r| RoleAppointmentPresenter.new(r, view_context) }
    @eighteenth_century_appointments = previous_appointments.between(DateTime.civil(1700), DateTime.civil(1800)).map { |r| RoleAppointmentPresenter.new(r, view_context) }
  end

  def past_chancellors
  end

  def show
    @person = PersonPresenter.new(Person.find(params[:person_id]))
    @historical_account = @person.historical_accounts.for_role(@role).first
    raise(ActiveRecord::RecordNotFound, "Couldn't find HistoricalAccount for #{@person.inspect}  and #{@role.inspect}") unless @historical_account
  end

  private

  def load_role
    @role = Role.find(role_id)
  end

  def role_id
    Role::HISTORIC_ROLE_PARAM_MAPPINGS[params[:role]]
  end

  def previous_appointments
    @previous_appointments ||= @role.previous_appointments.includes(:role, person: :historical_accounts).reorder('started_at DESC')
  end

  def previous_appointments_with_unique_people
    previous_appointments.uniq { |role_appointment| role_appointment.person }
  end
end
