class Speech < Announcement
  include Edition::Appointment

  after_save :populate_organisations_based_on_role_appointment

  validates :speech_type_id, :delivered_on, presence: true

  validate :role_appointment_has_associated_organisation, unless: ->(speech) { speech.can_have_some_invalid_data? }

  delegate :genus, :explanation, to: :speech_type
  validate :only_speeches_allowed_invalid_data_can_be_awaiting_type

  def speech_type
    SpeechType.find_by_id(speech_type_id)
  end

  def speech_type=(speech_type)
    self.speech_type_id = speech_type && speech_type.id
  end

  def display_type
    if [SpeechType::WrittenStatement, SpeechType::OralStatement].include?(speech_type)
      "Statement to parliament"
    else
      super
    end
  end

  def delivery_title
    role_appointment.role.ministerial? ? "Minister" : "Speaker"
  end

  private

  def skip_organisation_validation?
    true
  end

  def populate_organisations_based_on_role_appointment
    unless deleted? or organisations_via_role_appointment.empty?
      self.edition_organisations.clear
      organisations_via_role_appointment.each.with_index do |o, idx|
        self.edition_organisations.create!(organisation: o, lead: true, lead_ordering: idx)
      end
      reset_edition_organisations
    end
  end

  def organisations_via_role_appointment
    role_appointment && role_appointment.role && role_appointment.role.organisations || []
  end

  def set_timestamp_for_sorting
    self.timestamp_for_sorting = delivered_on
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
