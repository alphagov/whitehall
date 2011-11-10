class Role < ActiveRecord::Base
  has_many :role_appointments
  has_many :people, through: :role_appointments

  has_many :current_role_appointments, class_name: 'RoleAppointment', conditions: RoleAppointment::CURRENT_CONDITION
  has_many :current_people, class_name: 'Person', through: :current_role_appointments, source: :person

  has_many :organisation_roles
  has_many :organisations, through: :organisation_roles

  scope :alphabetical_by_person, includes(:people, :organisations).order("people.name ASC")

  validates :name, presence: true

  extend FriendlyId
  friendly_id :name, use: :slugged

  class << self
    def humanized_type
      name.gsub(/Role/, '').underscore.split("_").join(" ").humanize
    end
  end

  def humanized_type
    self.class.humanized_type
  end

  def should_generate_new_friendly_id?
    new_record?
  end

  def normalize_friendly_id(value)
    value = value.gsub(/'/, '') if value
    super value
  end

  def current_role_appointment
    current_role_appointments.first
  end

  def current_person
    current_people.first
  end

  def current_person_name(default="No one is assigned to this role")
    current_person ? current_person.name : default
  end

  def organisation_names
    organisations.map(&:name).join(' and ')
  end

  def to_s
    return "#{current_person.name} (#{name}, #{organisation_names})" if organisations.any? && current_person
    return "#{name}, #{organisation_names}" if organisations.any?
    return "#{current_person.name} (#{name})" if current_person
    return name
  end
end