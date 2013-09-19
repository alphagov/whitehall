class Consultation < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  include Edition::HasHtmlVersion
  include Edition::TopicalEvents
  include Edition::CanBeExternal

  validates :opening_on, presence: true, unless: ->(consultation) { consultation.can_have_some_invalid_data? }
  validates :closing_on, presence: true, unless: ->(consultation) { consultation.can_have_some_invalid_data? }

  validate :closing_on_must_be_after_opening_on

  has_one :outcome, class_name: 'ConsultationOutcome', foreign_key: :edition_id, dependent: :destroy
  has_one :public_feedback, class_name: 'ConsultationPublicFeedback', foreign_key: :edition_id, dependent: :destroy
  has_one :consultation_participation, foreign_key: :edition_id, dependent: :destroy

  after_update { |p| p.published_related_policies.each(&:update_published_related_publication_count) }

  accepts_nested_attributes_for :consultation_participation, reject_if: :all_blank_or_empty_hashes

  scope :closed, -> { where("closing_on < ?",  Date.today)}
  scope :closed_since, ->(earliest_closing_date) { closed.where('closing_on >= ?', earliest_closing_date.to_date) }
  scope :open, -> { where('closing_on >= ? AND opening_on <= ?', Date.today, Date.today) }
  scope :upcoming, -> { where('opening_on > ?', Date.today) }
  scope :responded, -> { joins(:outcome) }

  add_trait do
    def process_associations_after_save(edition)
      if @edition.consultation_participation.present?
        attributes = @edition.consultation_participation.attributes.except("id", "edition_id")
        edition.create_consultation_participation(attributes)
      end

      if @edition.outcome.present?
        new_outcome = edition.create_outcome(@edition.outcome.attributes.except('edition_id'))
        @edition.outcome.attachments.each do |attachment|
          new_outcome.consultation_response_attachments.create(attachment: Attachment.create(attachment.attributes))
        end
      end

      if @edition.public_feedback.present?
        new_feedback = edition.create_public_feedback(@edition.public_feedback.attributes.except('edition_id'))
        @edition.public_feedback.attachments.each do |attachment|
          new_feedback.consultation_response_attachments.create(attachment: Attachment.create(attachment.attributes))
        end
      end
    end
  end

  def allows_inline_attachments?
    false
  end

  def not_yet_open?
    opening_on.nil? || (opening_on > Date.today)
  end

  def open?
    opening_on.present? && !closed? && opening_on <= Date.today
  end

  def closed?
    closing_on.nil? || (closing_on < Date.today)
  end

  def outcome_published?
    closed? && outcome.present?
  end

  def outcome_published_on
    outcome.published_on
  end

  def first_public_at
    opening_on.to_datetime unless opening_on.nil?
  end

  def make_public_at(date)
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

  private

  def closing_on_must_be_after_opening_on
    if closing_on && opening_on && closing_on.to_date <= opening_on.to_date
      errors.add :closing_on,  "must be after the opening on date"
    end
  end
end
