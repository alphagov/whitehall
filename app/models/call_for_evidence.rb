class CallForEvidence < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  include Edition::TopicalEvents

  validates :opening_at, presence: true, unless: ->(call_for_evidence) { call_for_evidence.can_have_some_invalid_data? }
  validates :closing_at, presence: true, unless: ->(call_for_evidence) { call_for_evidence.can_have_some_invalid_data? }
  validates :external_url, presence: true, if: :external?
  validates :external_url, uri: true, allow_blank: true
  validate :validate_closes_after_opens

  has_one :outcome, class_name: "CallForEvidenceOutcome", foreign_key: :edition_id, dependent: :destroy
  has_one :public_feedback, class_name: "CallForEvidencePublicFeedback", foreign_key: :edition_id, dependent: :destroy
  has_one :call_for_evidence_participation, foreign_key: :edition_id, dependent: :destroy

  accepts_nested_attributes_for :call_for_evidence_participation, reject_if: :all_blank_or_empty_hashes

  scope :closed, -> { where("closing_at < ?", Time.zone.now) }
  scope :closed_at_or_after, ->(time) { closed.where("closing_at >= ?", time) }
  scope :closed_at_or_within_24_hours_of,
        lambda { |time|
          closed.where("? < closing_at AND closing_at <= ?", time - 24.hours, time)
        }
  scope :open, -> { where("closing_at >= ? AND opening_at <= ?", Time.zone.now, Time.zone.now) }
  scope :opened_at_or_after, ->(time) { open.where("opening_at >= ?", time) }
  scope :upcoming, -> { where("opening_at > ?", Time.zone.now) }
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

      if @edition.public_feedback.present?
        new_feedback = edition.build_public_feedback(@edition.public_feedback.attributes.except("id", "edition_id"))
        @edition.public_feedback.attachments.each do |attachment|
          new_feedback.attachments << attachment.deep_clone
        end
        new_feedback.save!
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
    [self, outcome, public_feedback].compact
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def allows_inline_attachments?
    false
  end

  def not_yet_open?
    opening_at.nil? || (opening_at > Time.zone.now)
  end

  def open?
    opening_at.present? && !closed? && opening_at <= Time.zone.now
  end

  def closed?
    closing_at.nil? || (closing_at < Time.zone.now)
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

    types = super + ["publicationesque-call_for_evidence", CallForEvidence.search_format_type]
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
    newly_created = document.nil?
    newly_created ? false : all_nation_applicability
  end

  def locale_can_be_changed?
    true
  end

  def string_for_slug
    title
  end

private

  def validate_closes_after_opens
    if closing_at && opening_at && closing_at.to_date <= opening_at.to_date
      errors.add :closing_at, "must be after the opening on date"
    end
  end
end
