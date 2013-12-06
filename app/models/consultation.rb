class Consultation < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  include Edition::TopicalEvents
  include Edition::CanBeExternal

  validates :opening_at, presence: true, unless: ->(consultation) { consultation.can_have_some_invalid_data? }
  validates :closing_at, presence: true, unless: ->(consultation) { consultation.can_have_some_invalid_data? }

  validate :validate_closes_after_opens

  has_one :outcome, class_name: 'ConsultationOutcome', foreign_key: :edition_id, dependent: :destroy
  has_one :public_feedback, class_name: 'ConsultationPublicFeedback', foreign_key: :edition_id, dependent: :destroy
  has_one :consultation_participation, foreign_key: :edition_id, dependent: :destroy

  after_update { |p| p.published_related_policies.each(&:update_published_related_publication_count) }

  accepts_nested_attributes_for :consultation_participation, reject_if: :all_blank_or_empty_hashes

  scope :closed, -> { where("closing_at < ?",  Time.zone.now) }
  scope :closed_since, ->(time) { closed.where('closing_at >= ?', time) }
  scope :open, -> { where('closing_at >= ? AND opening_at <= ?', Time.zone.now, Time.zone.now) }
  scope :upcoming, -> { where('opening_at > ?', Time.zone.now) }
  scope :responded, -> { joins(:outcome) }

  add_trait do
    def process_associations_after_save(edition)
      if @edition.consultation_participation.present?
        attributes = @edition.consultation_participation.attributes.except("id", "edition_id")
        edition.create_consultation_participation(attributes)
      end

      if @edition.outcome.present?
        new_outcome = edition.build_outcome(@edition.outcome.attributes.except('edition_id'))
        @edition.outcome.attachments.each do |attachment|
          new_outcome.attachments << attachment.class.new(attachment.attributes)
        end
        new_outcome.save!
      end

      if @edition.public_feedback.present?
        new_feedback = edition.build_public_feedback(@edition.public_feedback.attributes.except('edition_id'))
        @edition.public_feedback.attachments.each do |attachment|
          new_feedback.attachments << attachment.class.new(attachment.attributes)
        end
        new_feedback.save!
      end
    end
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

  def first_public_at
    opening_at.to_datetime unless opening_at.nil?
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

  def validate_closes_after_opens
    if closing_at && opening_at && closing_at.to_date <= opening_at.to_date
      errors.add :closing_at,  "must be after the opening on date"
    end
  end
end
