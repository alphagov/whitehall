class Role < ActiveRecord::Base
  has_many :role_appointments, order: 'started_at'
  has_many :people, through: :role_appointments

  has_many :current_role_appointments, class_name: 'RoleAppointment', conditions: RoleAppointment::CURRENT_CONDITION
  has_many :current_people, class_name: 'Person', through: :current_role_appointments, source: :person

  has_many :organisation_roles
  has_many :organisations, through: :organisation_roles

  has_many :worldwide_organisation_roles
  has_many :worldwide_organisations, through: :worldwide_organisation_roles

  scope :alphabetical_by_person, includes(:current_people, :organisations).order('people.surname', 'people.forename')

  scope :ministerial, where(type: 'MinisterialRole')
  scope :board_member, where(type: 'BoardMemberRole')
  scope :management, where("type = 'BoardMemberRole' OR type = 'ChiefScientificAdvisorRole'")
  scope :traffic_commissioner, where(type: 'TrafficCommissionerRole')
  scope :military, where(type: 'MilitaryRole')
  scope :special_representative, where(type: 'SpecialRepresentativeRole')

  validates :name, presence: true
  validates_with SafeHtmlValidator

  before_destroy :prevent_destruction_unless_destroyable

  extend FriendlyId
  friendly_id

  include TranslatableModel
  translates :name, :responsibilities

  def self.whip
    where(arel_table[:whip_organisation_id].not_eq(nil))
  end

  def occupied?
    current_role_appointments.any?
  end

  def current_role_appointment
    current_role_appointments.first
  end

  def current_person
    current_people.first
  end

  def previous_appointments
    role_appointments.where(["ended_at is not null AND ended_at < ?", Time.zone.now])
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

  def worldwide?
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
    role_appointments.empty? && organisations.empty? && worldwide_organisations.empty?
  end

  def seniority
    100
  end

  private

  def prevent_destruction_unless_destroyable
    return false unless destroyable?
  end
end
