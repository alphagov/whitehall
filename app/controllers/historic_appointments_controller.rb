class HistoricAppointmentsController < PublicFacingController
  before_action :load_role
  helper_method :previous_appointments_with_unique_people, :previous_appointments_list

  def index
    @recent_appointments = individual_role_appointees(all_recent_appointments)
    @twentieth_century_appointments = individual_role_appointees(all_twentieth_century_appointments)
    @eighteenth_and_nineteenth_century_appointments = individual_role_appointees(all_historical_appointments)
  end

  def show
    @person = PersonPresenter.new(Person.friendly.find(params[:id]), view_context)
    @historical_account = @person.historical_accounts.for_role(@role).first
    raise(ActiveRecord::RecordNotFound, "Couldn't find HistoricalAccount for #{@person.inspect}  and #{@role.inspect}") unless @historical_account
  end

private

  def all_recent_appointments
    present_roles(previous_appointments.where("started_at > ?", Date.civil(2001)))
  end

  def all_twentieth_century_appointments
    present_roles(previous_appointments.between(Date.civil(1901), Date.civil(2000)))
  end

  def all_historical_appointments
    present_roles(previous_appointments.between(Date.civil(1701), Date.civil(1900)))
  end

  def present_roles(roles)
    roles.map { |r| RoleAppointmentPresenter.new(r, view_context) }
  end

  def load_role
    @role = Role.friendly.find("prime-minister")
  end

  def previous_appointments
    @previous_appointments ||= @role.previous_appointments.includes(:role, person: :historical_accounts).reorder("started_at DESC")
  end

  def previous_appointments_with_unique_people
    previous_appointments.distinct(&:person)
  end

  def individual_role_appointees(appointments)
    appointments.uniq { |appointment| appointment.person.id }
  end

  def previous_appointments_list
    {
      "links" => {
        "ordered_related_items" => previous_appointments_with_unique_people.map do |role_appointment|
          {
            "title" => role_appointment.person.name,
            "base_path" => role_appointment.has_historical_account? ? "/government/history/#{@role.historic_param}/#{role_appointment.person.slug}" : "/government/history/#{@role.historic_param}",
          }
        end,
      },
    }
  end
end
