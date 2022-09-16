module Admin::RolesHelper
  def role_appointment_classes(role_appointment, *other_classes)
    ([role_appointment.type, "appointment"] + other_classes).join(" ")
  end

  def role_appointment_title(role_appointment)
    "#{role_appointment.type.capitalize} Appointment"
  end

  def roles_footnotes(roles, including_cabinet)
    text = roles.map { |role| role.footnotes(including_cabinet:) }.join(" ").html_safe
    tag.span(text, class: "app-person__footnotes")
  end

  def role_url_for(role)
    if role.new_record?
      admin_roles_path
    else
      admin_role_path(role.slug)
    end
  end
end
