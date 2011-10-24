class Role < ActiveRecord::Base
  has_many :role_appointments, conditions: RoleAppointment::CURRENT_CONDITION
  has_many :people, through: :role_appointments

  has_many :organisation_roles
  has_many :organisations, through: :organisation_roles

  scope :alphabetical_by_person, includes(:people, :organisations).order("people.name ASC")

  validates :name, presence: true

  extend FriendlyId
  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def current_role_appointment
    role_appointments.first
  end

  def person
    people.first
  end

  def person_name
    person ? person.name : "No one is assigned to this role"
  end

  def to_s
    organisation_names = organisations.map(&:name).join(' and ')
    return "#{person.name} (#{name}, #{organisation_names})" if organisations.any? && person
    return "#{name}, #{organisation_names}" if organisations.any?
    return "#{person.name} (#{name})" if person
    return name
  end
end