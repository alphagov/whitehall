class RoleAppointment < ActiveRecord::Base
  CURRENT_CONDITION = {ended_at: nil}

  has_many :speeches

  belongs_to :role
  belongs_to :person

  scope :for_role, -> role {
    where(role_id: role.id)
  }

  scope :excluding, -> *ids {
    where("id NOT IN (?)", ids)
  }

  after_create :make_other_appointments_non_current

  private

  def make_other_appointments_non_current
    other_appointments = self.class.for_role(role).excluding(self)
    other_appointments.update_all({ended_at: Time.zone.now})
  end
end