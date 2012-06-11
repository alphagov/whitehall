class RoleAppointment < ActiveRecord::Base
  CURRENT_CONDITION = {ended_at: nil}

  has_many :speeches

  belongs_to :role
  belongs_to :person

  class Validator < ActiveModel::Validator
    def validate(record)
      if record.make_current
        if record.before_any?
          record.errors[:started_at] << "should not be before any existing appointment"
        end
      elsif record.role && record.overlaps_any?
        record.errors[:base] << "should not overlap with any existing appointments"
      end
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

  validates :role, :person_id, :started_at, presence: true
  validates_with Validator

  scope :for_role, -> role {
    where(role_id: role.id)
  }

  scope :for_person, -> person {
    where(person_id: person.id)
  }

  scope :excluding, -> *ids {
    where("id NOT IN (?)", ids)
  }

  scope :current, where(CURRENT_CONDITION)

  after_create :make_other_current_appointments_non_current
  before_destroy :prevent_destruction_unless_destroyable

  attr_accessor :make_current

  def current?
    started_at.present? && ended_at.nil?
  end

  def type
    if new_record?
      "new"
    elsif current?
      "current"
    else
      "previous"
    end
  end

  def destroyable?
    persisted? && speeches.empty?
  end

  def before_any?
    other_appointments_for_same_role.where("started_at >= ?", started_at).exists?
  end

  def overlaps_any?
    overlapping_appointments.exists?
  end

  def overlapping_appointments
    if ended_at.nil?
      other_appointments_for_same_role.where("((:my_started_at BETWEEN started_at AND ended_at) AND :my_started_at != ended_at)" +
        "OR (started_at >= :my_started_at) " +
        "OR (ended_at IS NULL)", my_started_at: started_at)
    else
      other_appointments_for_same_role.where("((:my_started_at BETWEEN started_at AND ended_at) AND :my_started_at != ended_at)" +
        "OR ((started_at BETWEEN :my_started_at AND :my_ended_at) AND started_at != :my_ended_at)" +
        "OR (:my_ended_at > started_at AND ended_at IS NULL)",
        my_started_at: started_at, my_ended_at: ended_at)
    end
  end

  def other_appointments_for_same_role
    if persisted?
      self.class.for_role(role).excluding(self.id)
    else
      self.class.for_role(role)
    end
  end

  private

  def make_other_current_appointments_non_current
    return unless make_current
    other_appointments = other_appointments_for_same_role.current
    other_appointments.update_all({ended_at: started_at})
  end

  def prevent_destruction_unless_destroyable
    return false unless destroyable?
  end
end