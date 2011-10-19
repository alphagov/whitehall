class MinisterialRole < Role
  has_many :ministerial_appointments, conditions: MinisterialAppointment::CURRENT_CONDITION
  has_many :people, through: :ministerial_appointments

  has_many :organisation_ministerial_roles
  has_many :organisations, through: :organisation_ministerial_roles

  has_many :document_ministerial_roles
  has_many :documents, through: :document_ministerial_roles

  scope :alphabetical_by_person, includes(:people, :organisations).order("people.name ASC")

  validates :name, presence: true

  def person
    current_appointment = ministerial_appointments.first
    current_appointment ? current_appointment.person : nil
  end

  def to_s
    organisation_names = organisations.map(&:name).join(' and ')
    return "#{person.name} (#{name}, #{organisation_names})" if organisations.any? && person
    return "#{name}, #{organisation_names}" if organisations.any?
    return "#{person.name} (#{name})" if person
    return name
  end

  def person_name
    person ? person.name : "No one is assigned to this role"
  end
end