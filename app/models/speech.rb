class Speech < Edition
  include Document::RelatedPolicies
  include Document::Countries
  extend Forwardable

  belongs_to :role_appointment

  validates :role_appointment, :speech_type_id, :delivered_on, presence: true

  before_save :populate_organisations_based_on_role_appointment

  def_delegators :speech_type, :genus, :explanation
  def_delegators :role_appointment, :role

  def speech_type
    SpeechType.find_by_id(speech_type_id)
  end

  def speech_type=(speech_type)
    self.speech_type_id = speech_type && speech_type.id
  end

  def has_summary?
    true
  end

  def person
    role_appointment.person
  end

  private

  def populate_organisations_based_on_role_appointment
    organisation_associations = role_appointment.role.organisations.map do |organisation|
      if existing = document_organisations.detect {|candidate| candidate.organisation_id = organisation.id }
        existing
      else
        document_organisations.build organisation: organisation
      end
    end
    self.document_organisations = organisation_associations
  end
end
