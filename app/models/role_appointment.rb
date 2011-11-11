class RoleAppointment < ActiveRecord::Base
  CURRENT_CONDITION = {ended_at: nil}

  has_many :speeches

  belongs_to :role
  belongs_to :person

  class ArrowOfTimeValidator < ActiveModel::Validator
    def validate(record)
      if record.ended_at && (record.ended_at < record.started_at)
        record.errors[:ends_at] << "should not be before appointment starts"
      end
    end
  end

  validates :role, :person, :started_at, presence: true
  validates_with ArrowOfTimeValidator

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