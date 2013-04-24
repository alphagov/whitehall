module HistoricAppointmentsHelper
  def historical_fact(title, text)
    return if text.blank?
    content_tag(:h3, title) + content_tag(:p, text)
  end

  def previous_dates_in_office(role, person)
    RoleAppointmentPresenter.decorate(role.previous_appointments.for_person(person)).collect(&:date_range).join(', ')
  end
end
