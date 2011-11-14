class RoleAppointment < ActiveRecord::Base
  CURRENT_CONDITION = {ended_at: nil}

  has_many :speeches

  belongs_to :role
  belongs_to :person

  class Validator < ActiveModel::Validator
    def validate(record)
      if record.ended_at && (record.ended_at < record.started_at)
        record.errors[:ends_at] << "should not be before appointment starts"
      end
      [:started_at, :ended_at].each do |attribute|
        if record.send(attribute) && (record.send(attribute) > Time.zone.now)
          record.errors[attribute] << "should not be in the future"
        end
      end
    end
  end

  validates :role, :person, :started_at, presence: true
  validates_with Validator

  scope :for_role, -> role {
    where(role_id: role.id)
  }

  scope :excluding, -> *ids {
    where("id NOT IN (?)", ids)
  }

  scope :current, where(CURRENT_CONDITION)

  after_create :make_other_current_appointments_non_current
  before_destroy :prevent_destruction_unless_destroyable

  def current?
    started_at.present? && ended_at.nil?
  end

  def destroyable?
    speeches.empty?
  end

  private

  def make_other_current_appointments_non_current
    other_appointments = self.class.for_role(role).current.excluding(self)
    other_appointments.update_all({ended_at: Time.zone.now})
  end

  def prevent_destruction_unless_destroyable
    return false unless destroyable?
  end
end