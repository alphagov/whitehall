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
      "image_url" => lead_image_url,
    )
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

  def display_type
    if speech_type.statement_to_parliament?
      I18n.t("document.type.statement_to_parliament", count: 1)
    else
      I18n.t("document.type.speech", count: 1)
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

  def base_path
    "/government/speeches/#{slug}"
  end

  def publishing_api_presenter
    PublishingApi::SpeechPresenter
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
end
