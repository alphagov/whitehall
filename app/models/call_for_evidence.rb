class CallForEvidence < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  include Edition::TopicalEvents
  include Edition::HasOpeningAndClosingDates

  validates :external_url, presence: true, if: :external?
  validates :external_url, uri: true, allow_blank: true
  validate :call_for_evidence_response_file_uploaded_to_asset_manager!, if: :call_for_evidence_response_file_in_asset_manager_check_required?

  has_one :call_for_evidence_participation, foreign_key: :edition_id, dependent: :destroy
  has_one :outcome, class_name: "CallForEvidenceOutcome", foreign_key: :edition_id, dependent: :destroy

  accepts_nested_attributes_for :call_for_evidence_participation, reject_if: :all_blank_or_empty_hashes

  scope :responded, -> { joins(:outcome) }
  scope :awaiting_response, -> { published.closed.where.not(id: responded.pluck(:id)) }

  add_trait do
    def process_associations_after_save(edition)
      if @edition.call_for_evidence_participation.present?
        attributes = @edition.call_for_evidence_participation.attributes.except("id", "edition_id")
        edition.create_call_for_evidence_participation(attributes)
      end

      if @edition.outcome.present?
        new_outcome = edition.build_outcome(@edition.outcome.attributes.except("id", "edition_id"))
        @edition.outcome.attachments.each do |attachment|
          new_outcome.attachments << attachment.deep_clone
        end
        new_outcome.save!
      end
    end
  end

  # A call_for_evidence changes outside the edition workflow when it opens or
  # closes. We need to republish the call_for_evidence at these times to ensure
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
    [self, outcome].compact
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def allows_inline_attachments?
    false
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

  def has_call_for_evidence_participation?
    call_for_evidence_participation.present?
  end

  def display_type_key
    if outcome_published?
      "call_for_evidence_outcome"
    elsif closed?
      "closed_call_for_evidence"
    elsif open?
      "open_call_for_evidence"
    else
      "call_for_evidence"
    end
  end

  def search_format_types
    call_for_evidence_type =
      if outcome_published?
        "call-for-evidence-outcome"
      elsif closed?
        "call-for-evidence-closed"
      elsif open?
        "call-for-evidence-open"
      end

    types = super + ["publicationesque-call-for-evidence", CallForEvidence.search_format_type]
    types << call_for_evidence_type if call_for_evidence_type
    types
  end

  def search_index
    super.merge(
      end_date: closing_at,
      start_date: opening_at,
      has_official_document: has_official_document? || (outcome.present? && outcome.has_official_document?),
      has_command_paper: has_command_paper? || (outcome.present? && outcome.has_command_paper?),
      has_act_paper: has_act_paper? || (outcome.present? && outcome.has_act_paper?),
    )
  end

  def allows_html_attachments?
    true
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
    "/government/calls-for-evidence/#{slug}"
  end

  def publishing_api_presenter
    PublishingApi::CallForEvidencePresenter
  end

  def call_for_evidence_response_file_in_asset_manager_check_required?
    has_call_for_evidence_participation? && call_for_evidence_participation.has_response_form? && published?
  end

  def call_for_evidence_response_file_uploaded_to_asset_manager!
    errors.add(:call_for_evidence_response_form, "must have finished uploading") unless call_for_evidence_participation.call_for_evidence_response_form_uploaded_to_asset_manager?
  end
end
