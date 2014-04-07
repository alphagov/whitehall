class Speech < Announcement
  include Edition::Appointment
  include Edition::HasDocumentCollections
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies

  validates :speech_type_id, presence: true
  validates :delivered_on, presence: true, unless: ->(speech) { speech.can_have_some_invalid_data? }

  delegate :display_type_key, :explanation, to: :speech_type
  validate :only_speeches_allowed_invalid_data_can_be_awaiting_type

  def self.subtypes
    SpeechType.all
  end

  def self.by_subtype(subtype)
    where(speech_type_id: subtype.id)
  end

  def self.by_subtypes(subtype_ids)
    where(speech_type_id: subtype_ids)
  end

  def search_format_types
    super + [Speech.search_format_type] + speech_type.search_format_types
  end

  def speech_type
    SpeechType.find_by_id(speech_type_id)
  end

  def speech_type=(speech_type)
    self.speech_type_id = speech_type.id if speech_type
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
    can_have_some_invalid_data? || person_override.present?
  end

  def only_speeches_allowed_invalid_data_can_be_awaiting_type
    unless self.can_have_some_invalid_data?
      errors.add(:speech_type, 'must be changed') if SpeechType::ImportedAwaitingType == self.speech_type
    end
  end
end
