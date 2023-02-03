class HistoricAppointmentsController < PublicFacingController
  before_action :load_role
  helper_method :previous_appointments_with_unique_people, :previous_appointments_list

  def show
    @person = PersonPresenter.new(Person.friendly.find(params[:id]), view_context)
    @historical_account = @person.historical_accounts.for_role(@role).first
    raise(ActiveRecord::RecordNotFound, "Couldn't find HistoricalAccount for #{@person.inspect}  and #{@role.inspect}") unless @historical_account
  end

private

  def load_role
    @role = Role.friendly.find("prime-minister")
  end

  def previous_appointments_with_unique_people
    previous_appointments.distinct(&:person)
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
