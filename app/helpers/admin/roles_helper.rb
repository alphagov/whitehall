module Admin::RolesHelper

  def role_appointment_classes(role_appointment, *other_classes)
    ([role_appointment.type, "appointment"] + other_classes).join(" ")
  end

  def role_appointment_title(role_appointment)
    "#{role_appointment.type.capitalize} Appointment"
  end

  def roles_footnotes(roles)
    content_tag(:span, roles.map { |role| role.footnotes }.join(" ").html_safe)
  end
end