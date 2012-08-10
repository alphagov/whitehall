class Consultation < Edition
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include Edition::Attachable
  include Edition::Featurable
  include Edition::AlternativeFormatProvider

  validates :opening_on, presence: true
  validates :closing_on, presence: true
  validate :closing_on_must_be_after_opening_on

  has_many :consultation_responses, through: :document
  has_one :published_consultation_response, through: :document

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
