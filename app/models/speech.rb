class Speech < Announcement
  include Edition::Appointment
  include Edition::HasDocumentCollections
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  include LeadImagePresenterHelper

  validates :speech_type_id, presence: true
  validates :delivered_on, presence: true, unless: ->(speech) { speech.can_have_some_invalid_data? }

  delegate :display_type_key, :explanation, to: :speech_type

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

  def search_index
    super.merge(
      "image_url" => lead_image_url
    )
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

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

private

  def date_for_government
    if delivered_on && delivered_on.past?
      delivered_on.to_date
    else
      super
    end
  end

  def skip_organisation_validation?
    can_have_some_invalid_data? || person_override.present?
  end

  def lead_image_url
    ActionController::Base.helpers.image_url(
      lead_image_path, host: Whitehall.public_asset_host
    )
  end
end
