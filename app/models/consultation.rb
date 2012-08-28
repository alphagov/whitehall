class Consultation < Edition
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include Edition::Attachable

  validates :opening_on, presence: true
  validates :closing_on, presence: true
  validate :closing_on_must_be_after_opening_on

  has_one :consultation_participation, foreign_key: :edition_id, dependent: :destroy
  has_many :consultation_responses, through: :document
  has_one :published_consultation_response, through: :document

  accepts_nested_attributes_for :consultation_participation, reject_if: :all_blank

  add_trait do
    def process_associations_after_save(edition)
      if @edition.consultation_participation.present?
        attributes = @edition.consultation_participation.attributes.except("id", "edition_id")
        edition.create_consultation_participation(attributes)
      end
    end
  end

  def latest_consultation_response
    consultation_responses.order("id DESC").first
  end

  def not_yet_open?
    opening_on > Date.today
  end

  def open?
    !closed? && opening_on <= Date.today
  end

  def closed?
    closing_on < Date.today
  end

  def has_summary?
    true
  end

  def response_published?
    closed? && published_consultation_response.present?
  end

  def response_published_on
    published_consultation_response.first_published_at.to_date
  end

  def last_significantly_changed_on
    ((response_published? && response_published_on) || (closed? && closing_on) || (open? && opening_on) || first_published_at).to_date
  end

  def allows_attachment_references?
    true
  end

  def has_consultation_participation?
    consultation_participation.present?
  end

  private

  def closing_on_must_be_after_opening_on
    if closing_on && opening_on && closing_on.to_date <= opening_on.to_date
      errors.add :closing_on,  "must be after the opening on date"
    end
  end

  class << self
    def closed
      where 'closing_on < :today', today: Date.today
    end

    def open
      where 'closing_on >= :today AND opening_on <= :today', today: Date.today
    end

    def upcoming
      where 'opening_on > :today', today: Date.today
    end
  end
end
