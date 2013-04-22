module HistoricAppointmentsHelper
  def historical_fact(title, text)
    return if text.blank?
    content_tag(:h3, title) + content_tag(:p, text)
  end

  def historic_appointment_path(role, person)
    url_for({ controller: '/historic_appointments', action: :show, role: role.historic_param, person_id: person })
  end
end
