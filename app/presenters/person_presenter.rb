class PersonPresenter < Draper::Base
  decorates :person

  def current_role_appointments
    RoleAppointmentPresenter.decorate model.current_role_appointments
  end

  def previous_role_appointments
    RoleAppointmentPresenter.decorate model.previous_role_appointments
  end

  def link
    h.link_to name, url
  end

  def url
    h.person_url model
  end
end