class Role < ActiveRecord::Base
  has_many :role_appointments, order: 'started_at'
  has_many :people, through: :role_appointments

  has_many :current_role_appointments, class_name: 'RoleAppointment', conditions: RoleAppointment::CURRENT_CONDITION
  has_many :current_people, class_name: 'Person', through: :current_role_appointments, source: :person

  has_many :organisation_roles
  has_many :organisations, through: :organisation_roles

  scope :alphabetical_by_person, includes(:current_people, :organisations).order('people.surname', 'people.forename')

  validates :name, presence: true

  before_destroy :prevent_destruction_unless_destroyable

  extend FriendlyId
  friendly_id :name, use: :slugged

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

  delegate :surname, to: :current_person, prefix: true, allow_nil: true

  def current_person_image_url
    current_person && current_person.image_url
  end

  def current_person_biography
    current_person && current_person.biography
  end

  def organisation_names
    organisations.map(&:name).join(' and ')
  end

  def name_and_organisations
    if organisations.any?
      "#{name}, #{organisation_names}"
    else
      name
    end
  end

  def ministerial?
    false
  end

  def to_s
    if organisations.any?
      "#{name}, #{organisation_names}"
    else
      name
    end
  end

  def destroyable?
    role_appointments.empty? && organisations.empty?
  end

  private

  def prevent_destruction_unless_destroyable
    return false unless destroyable?
  end
end