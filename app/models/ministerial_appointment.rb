class MinisterialAppointment < ActiveRecord::Base
  CURRENT_CONDITION = {ended_at: nil}

  belongs_to :ministerial_role
  belongs_to :person

  scope :for_ministerial_role, -> ministerial_role {
    where(ministerial_role_id: ministerial_role.id)
  }

  scope :excluding, -> *ids {
    where("id NOT IN (?)", ids)
  }

  after_create :make_other_appointments_non_current

  private

  def make_other_appointments_non_current
    other_appointments = self.class.for_ministerial_role(ministerial_role).excluding(self)
    other_appointments.update_all({ended_at: Time.zone.now})
  end
end