class Speech < Document
  include Document::RelatedPolicies
  include Document::Countries

  belongs_to :role_appointment
  belongs_to :speech_type

  validates :role_appointment, :speech_type, :delivered_on, :location, presence: true

  before_save :populate_organisations_based_on_role_appointment

  def has_summary?
    true
  end

  private

  def populate_organisations_based_on_role_appointment
    self.organisations = role_appointment.role.organisations
  end
end
