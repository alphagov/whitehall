class Speech < Edition
  include Edition::Appointment
  include Edition::HasDocumentCollections
  include Edition::LeadImage
  include Edition::Images
  include Edition::Organisations
  include Edition::TaggableOrganisations
  include Edition::WorldLocations
  include Edition::TopicalEvents

  validates :speech_type_id, presence: true
  validates :delivered_on, presence: true, unless: ->(speech) { speech.can_have_some_invalid_data? }

  delegate :explanation, to: :speech_type

  def self.by_subtype(subtype)
    where(speech_type_id: subtype.id)
  end

  def display_type_key
    speech_type&.key || SpeechType.genus_key
  end

  def speech_type
    SpeechType.find_by_id(speech_type_id)
  end

  def speech_type=(speech_type)
    self.speech_type_id = speech_type.id if speech_type
  end

  def authored_article?
    speech_type == SpeechType::AuthoredArticle
  end

  def translatable?
    !non_english_edition?
  end

  def delivered_by_minister?
    role_appointment && role_appointment.role && role_appointment.role.ministerial?
  end

  def rendering_app
    Whitehall::RenderingApp::FRONTEND
  end

  def base_path
    "/government/speeches/#{slug}"
  end

  def publishing_api_presenter
    PublishingApi::SpeechPresenter
  end

  def organisation_association_enabled?
    !can_have_some_invalid_data? && person_override.blank?
  end

private

  def date_for_government
    if delivered_on && delivered_on.past?
      delivered_on.to_date
    else
      super
    end
  end
end
