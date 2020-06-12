module HistoricAppointmentsHelper
  def historical_fact(title, text)
    return if text.blank?

    tag.h3(title) + tag.p(text)
  end

  def previous_dates_in_office(role, person)
    role.previous_appointments.for_person(person)
         .map { |r| RoleAppointmentPresenter.new(r, self).date_range }
         .join(", ")
  end
end
