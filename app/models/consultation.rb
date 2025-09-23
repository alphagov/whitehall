class Consultation < Edition
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::TopicalEvents
  include Edition::HasOpeningAndClosingDates
  include Edition::HasDocumentCollections
  include Edition::Organisations
  include Edition::TaggableOrganisations

  include ::Attachable

  validates :external_url, presence: true, if: :external?
  validates :external_url, uri: true, allow_blank: true
  validate :validate_consultation_principles, unless: ->(consultation) { Edition::PRE_PUBLICATION_STATES.include? consultation.state }
  validate :consultation_response_file_uploaded_to_asset_manager!, if: :consultation_response_file_in_asset_manager_check_required?

  has_one :outcome, class_name: "ConsultationOutcome", foreign_key: :edition_id, dependent: :destroy
  has_one :public_feedback, class_name: "ConsultationPublicFeedback", foreign_key: :edition_id, dependent: :destroy
  has_one :consultation_participation, foreign_key: :edition_id, dependent: :destroy

  accepts_nested_attributes_for :consultation_participation, reject_if: :all_blank_or_empty_hashes

  scope :responded, -> { joins(:outcome) }
  scope :awaiting_response, -> { published.closed.where.not(id: responded.pluck(:id)) }

  add_trait do
    def process_associations_after_save(edition)
      if @edition.consultation_participation.present?
        attributes = @edition.consultation_participation.attributes.except("id", "edition_id")
        edition.create_consultation_participation(attributes)
      end

      if @edition.outcome.present?
        new_outcome = edition.build_outcome(@edition.outcome.attributes.except("id", "edition_id"))
        @edition.outcome.attachments.each do |attachment|
          new_outcome.attachments << attachment.deep_clone
        end
        new_outcome.save!
      end

      if @edition.public_feedback.present?
        new_feedback = edition.build_public_feedback(@edition.public_feedback.attributes.except("id", "edition_id"))
        @edition.public_feedback.attachments.each do |attachment|
          new_feedback.attachments << attachment.deep_clone
        end
        new_feedback.save!
      end
    end
  end

  # A consultation changes outside the edition workflow when it opens or
  # closes. We need to republish the consultation at these times to ensure
  # changes are reflected in any external systems.
  after_save do
    schedule_republishing_workers
  end

  def schedule_republishing_workers
    if opening_at.try(:future?)
      PublishingApiDocumentRepublishingWorker
        .perform_at(opening_at, document.id)
    end

    if closing_at.try(:future?)
      PublishingApiDocumentRepublishingWorker
        .perform_at(closing_at, document.id)
    end
  end

  def attachables
    [self, outcome, public_feedback].compact
  end

  def delete_all_attachments
    attachables.map(&:attachments).flatten.each(&:destroy)
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def outcome_published?
    closed? && outcome.present?
  end

  delegate :published_on, to: :outcome, prefix: true

  def allows_attachment_references?
    true
  end

  def can_have_attached_house_of_commons_papers?
    true
  end

  def can_set_previously_published?
    false
  end

  def has_consultation_participation?
    consultation_participation.present?
  end

  def display_type_key
    if outcome_published?
      "consultation_outcome"
    elsif closed?
      "closed_consultation"
    elsif open?
      "open_consultation"
    else
      "consultation"
    end
  end

  def allows_html_attachments?
    true
  end

  def associated_documents
    attachables.flat_map(&:html_attachments)
  end

  def deleted_associated_documents
    attachables.flat_map(&:deleted_html_attachments)
  end

  def previously_published
    false
  end

  def all_nation_applicability_selected?
    newly_created = document.nil? || document.new_record?
    newly_created ? false : all_nation_applicability
  end

  def locale_can_be_changed?
    true
  end

  def string_for_slug
    title
  end

  def base_path
    "/government/consultations/#{slug}"
  end

  def publishing_api_presenter
    PublishingApi::ConsultationPresenter
  end

private

  def validate_consultation_principles
    unless read_consultation_principles
      errors.add :read_consultation_principles, "must be ticked"
    end
  end

  def consultation_response_file_in_asset_manager_check_required?
    has_consultation_participation? && consultation_participation.has_response_form? && published?
  end

  def consultation_response_file_uploaded_to_asset_manager!
    errors.add(:consultation_response_form, "must have finished uploading") unless consultation_participation.consultation_response_form_uploaded_to_asset_manager?
  end

  def all_blank_or_empty_hashes(attributes)
    attributes.values.reduce(true) do |result, value|
      result && (value.is_a?(Hash) ? all_blank_or_empty_hashes(value) : value.blank?)
    end
  end
end
