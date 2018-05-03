class Consultation < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  include Edition::TopicalEvents

  validates :opening_at, presence: true, unless: ->(consultation) { consultation.can_have_some_invalid_data? }
  validates :closing_at, presence: true, unless: ->(consultation) { consultation.can_have_some_invalid_data? }
  validates :external_url, presence: true, if: :external?
  validates :external_url, uri: true, allow_blank: true
  validate :validate_closes_after_opens
  validate :validate_consultation_principles, unless: ->(consultation) { Edition::PRE_PUBLICATION_STATES.include? consultation.state }

  has_one :outcome, class_name: 'ConsultationOutcome', foreign_key: :edition_id, dependent: :destroy
  has_one :public_feedback, class_name: 'ConsultationPublicFeedback', foreign_key: :edition_id, dependent: :destroy
  has_one :consultation_participation, foreign_key: :edition_id, dependent: :destroy

  accepts_nested_attributes_for :consultation_participation, reject_if: :all_blank_or_empty_hashes

  scope :closed, -> { where("closing_at < ?", Time.zone.now) }
  scope :closed_at_or_after, ->(time) { closed.where('closing_at >= ?', time) }
  scope :closed_at_or_within_24_hours_of, ->(time) {
    closed.where("? < closing_at AND closing_at <= ?", time - 24.hours, time)
  }
  scope :open, -> { where('closing_at >= ? AND opening_at <= ?', Time.zone.now, Time.zone.now) }
  scope :opened_at_or_after, ->(time) { open.where('opening_at >= ?', time) }
  scope :upcoming, -> { where('opening_at > ?', Time.zone.now) }
  scope :responded, -> { joins(:outcome) }
  scope :awaiting_response, -> { closed.where.not(id: responded.pluck(:id)) }

  add_trait do
    def process_associations_after_save(edition)
      if @edition.consultation_participation.present?
        attributes = @edition.consultation_participation.attributes.except('id', 'edition_id')
        edition.create_consultation_participation(attributes)
      end

      if @edition.outcome.present?
        new_outcome = edition.build_outcome(@edition.outcome.attributes.except('id', 'edition_id'))
        @edition.outcome.attachments.each do |attachment|
          new_outcome.attachments << attachment.deep_clone
        end
        new_outcome.save!
      end

      if @edition.public_feedback.present?
        new_feedback = edition.build_public_feedback(@edition.public_feedback.attributes.except('id', 'edition_id'))
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

  def outcome_published_on
    outcome.published_on
  end

  def allows_attachment_references?
    true
  end

  def can_have_attached_house_of_commons_papers?
    true
  end

  def has_consultation_participation?
    consultation_participation.present?
  end

  def display_type
    if outcome_published?
      "Consultation outcome"
    elsif closed?
      "Closed consultation"
    elsif open?
      "Open consultation"
    else
      "Consultation"
    end
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

  def search_format_types
    consultation_type =
      if outcome_published?
        'consultation-outcome'
      elsif closed?
        'consultation-closed'
      elsif open?
        'consultation-open'
      end

    types = super + ['publicationesque-consultation', Consultation.search_format_type]
    types << consultation_type if consultation_type
    types
  end

  def search_index
    super.merge(
      has_official_document: has_official_document? || (outcome.present? && outcome.has_official_document?),
      has_command_paper: has_command_paper? || (outcome.present? && outcome.has_command_paper?),
      has_act_paper: has_act_paper? || (outcome.present? && outcome.has_act_paper?)
    )
  end

  def allows_html_attachments?
    true
  end

private

  def validate_closes_after_opens
    if closing_at && opening_at && closing_at.to_date <= opening_at.to_date
      errors.add :closing_at, "must be after the opening on date"
    end
  end

  def validate_consultation_principles
    unless read_consultation_principles
      errors.add :read_consultation_principles, "must be ticked"
    end
  end
end
