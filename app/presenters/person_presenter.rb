class PersonPresenter < Draper::Base
  decorates :person

  def current_role_appointments
    RoleAppointmentPresenter.decorate model.current_role_appointments
  end

  def previous_role_appointments
    RoleAppointmentPresenter.decorate model.previous_role_appointments
  end

  def biography
    h.govspeak_to_html model.biography
  end

  def link
    h.link_to name, path
  end

  def path
    h.person_path model
  end

  def image
    img = image_url || 'blank-person.png'
    h.image_tag img, alt: nil
  end
end
