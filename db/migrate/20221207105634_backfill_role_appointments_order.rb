class BackfillRoleAppointmentsOrder < ActiveRecord::Migration[7.0]
  def up
    Person.joins(:role_appointments).find_each do |person|
      person.role_appointments.each_with_index do |role_appointment, index|
        role_appointment.update_column("order", index + 1)
      end
    end
  end

  def down
    RoleAppointment.update_all(order: nil)
  end
end
