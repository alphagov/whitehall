module Admin::RolesHelper
  def role_appointment_type(role_appointment)
    if role_appointment.new_record?
      "New Appointment"
    elsif role_appointment.current?
      "Current Appointment"
    else
      "Previous Appointment"
    end
  end
end