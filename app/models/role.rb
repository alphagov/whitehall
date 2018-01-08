# @abstract
class Role < ApplicationRecord
  include HasContentId
  HISTORIC_ROLE_PARAM_MAPPINGS = { 'past-prime-ministers' => 'prime-minister',
                                   'past-chancellors'     => 'chancellor-of-the-exchequer',
                                   'past-foreign-secretaries' => 'foreign-secretary' }.freeze

  def self.columns
    # This is here to enable us to gracefully remove the biography column
    # in a future commit, *after* this change has been deployed
    super.reject { |column| ['name', 'responsibilities'].include?(column.name) }
  end

  has_many :role_appointments, -> { order(started_at: :desc) }
  has_many :people, through: :role_appointments

  has_many :current_role_appointments,
           -> { where(RoleAppointment::CURRENT_CONDITION) },
           class_name: 'RoleAppointment'
  has_many :current_people, class_name: 'Person', through: :current_role_appointments, source: :person

  has_many :organisation_roles, inverse_of: :role
  has_many :organisations, through: :organisation_roles

  has_many :worldwide_organisation_roles, inverse_of: :role
  has_many :worldwide_organisations, through: :worldwide_organisation_roles

  has_many :historical_account_roles, inverse_of: :role
  has_many :historical_accounts, through: :historical_account_roles

  scope :alphabetical_by_person,     -> { includes(:current_people, :organisations).order('people.surname', 'people.forename') }

  scope :ministerial,                -> { where(type: 'MinisterialRole') }
  scope :board_member,               -> { where(type: 'BoardMemberRole') }
  scope :management,                 -> { where("type = 'BoardMemberRole' OR type = 'ChiefScientificAdvisorRole'") }
  scope :traffic_commissioner,       -> { where(type: 'TrafficCommissionerRole') }
  scope :military,                   -> { where(type: 'MilitaryRole') }
  scope :special_representative,     -> { where(type: 'SpecialRepresentativeRole') }
  scope :chief_professional_officer, -> { where(type: 'ChiefProfessionalOfficerRole') }
  scope :occupied,                   -> { where(id: RoleAppointment.current.pluck(:role_id)) }

  validates :name, presence: true
  validates :type, presence: true
  validates_with SafeHtmlValidator

  before_destroy :prevent_destruction_unless_destroyable
  after_update :touch_role_appointments

  extend FriendlyId
  friendly_id

  include TranslatableModel
  translates :name, :responsibilities

  def self.whip
    where(arel_table[:whip_organisation_id].not_eq(nil))
  end

  def role_payment_type
    RolePaymentType.find_by_id(role_payment_type_id)
  end

  def attends_cabinet_type
    RoleAttendsCabinetType.find_by_id(attends_cabinet_type_id)
  end

  def self.also_attends_cabinet
    where(arel_table[:attends_cabinet_type_id].not_eq(nil))
  end

  def footnotes(including_cabinet = false)
    if including_cabinet
      note = []
      note << attends_cabinet_type.name if attends_cabinet_type_id == 2
      note << role_payment_type.name if role_payment_type
      note.join(". ")
    else
      role_payment_type.name if role_payment_type
    end
  end

  def role_type
    RoleTypePresenter.option_value_for(self, self.type)
  end

  def role_type=(role_type)
    unless role_type.blank?
      role_attributes = RoleTypePresenter.role_attributes_from(role_type)
      self.attributes = role_attributes.except(:type)
    end
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

  def current_person_name
    current_person.try(:name) || default_person_name
  end

  delegate :surname, to: :current_person, prefix: true, allow_nil: true

  def current_person_image_url
    current_person && current_person.image_url
  end

  def current_person_biography
    current_person && current_person.biography_without_markup
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

  def historic_param
    HISTORIC_ROLE_PARAM_MAPPINGS.invert[slug]
  end

private

  def prevent_destruction_unless_destroyable
    throw :abort unless destroyable?
  end

  def default_person_name
    "No one is assigned to this role"
  end

  # Whenever a ministerial role is updated, we want touch the updated_at
  # timestamps of any associated role appointments so that the cache digest for
  # the taggable_ministerial_role_appointments_container gets invalidated.
  def touch_role_appointments
    role_appointments.update_all updated_at: Time.zone.now
  end
end
