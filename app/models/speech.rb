class Speech < Announcement
  include Edition::Appointment
  include Edition::HasDocumentSeries
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies

  after_save :populate_organisations_based_on_role_appointment, unless: ->(speech) { speech.person_override? }

  validates :speech_type_id, presence: true
  validates :delivered_on, presence: true, unless: ->(speech) { speech.can_have_some_invalid_data? }

  validate :role_appointment_has_associated_organisation, unless: ->(speech) { speech.can_have_some_invalid_data? || speech.person_override? }

  delegate :display_type_key, :explanation, to: :speech_type
  validate :only_speeches_allowed_invalid_data_can_be_awaiting_type

  def search_format_types
    super + [Speech.search_format_type] + speech_type.search_format_types
  end

  def speech_type
    SpeechType.find_by_id(speech_type_id)
  end

  def speech_type=(speech_type)
    self.speech_type_id = speech_type && speech_type.id
  end

  def display_type
    if speech_type.statement_to_parliament?
      "Statement to Parliament"
    else
      super
    end
  end

  def translatable?
    !non_english_edition?
  end

  def delivered_by_minister?
    role_appointment && role_appointment.role && role_appointment.role.ministerial?
  end

  private

  def skip_organisation_validation?
    true
  end

  def populate_organisations_based_on_role_appointment
    unless deleted? || organisations_via_role_appointment.empty?
      self.edition_organisations.clear
      organisations_via_role_appointment.each.with_index do |o, idx|
        self.edition_organisations.create!(organisation: o, lead: true, lead_ordering: idx)
      end
    end
  end

  def organisations_via_role_appointment
    role_appointment && role_appointment.role && role_appointment.role.organisations || []
  end

  def role_appointment_has_associated_organisation
    unless organisations_via_role_appointment.any?
      errors.add(:role_appointment, "must have an associated organisation")
    end
  end

  def only_speeches_allowed_invalid_data_can_be_awaiting_type
    unless self.can_have_some_invalid_data?
      errors.add(:speech_type, 'must be changed') if SpeechType::ImportedAwaitingType == self.speech_type
    end
  end
end
