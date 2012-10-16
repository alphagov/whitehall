class Speech < Announcement
  include Edition::Appointment

  validates :speech_type_id, :delivered_on, presence: true
  before_save :populate_organisations_based_on_role_appointment

  delegate :genus, :explanation, to: :speech_type

  def speech_type
    SpeechType.find_by_id(speech_type_id)
  end

  def speech_type=(speech_type)
    self.speech_type_id = speech_type && speech_type.id
  end

  private

  def populate_organisations_based_on_role_appointment
    organisation_associations = role_appointment.role.organisations.map do |organisation|
      if existing = edition_organisations.detect {|candidate| candidate.organisation_id = organisation.id }
        existing
      else
        edition_organisations.build organisation: organisation
      end
    end
    self.edition_organisations = organisation_associations
  end
end
