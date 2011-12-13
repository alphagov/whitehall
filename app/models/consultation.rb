class Consultation < Document
  include Document::NationalApplicability
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedDocuments
  include Document::Attachable

  scope :featured, where(featured: true)

  validates :opening_on, presence: true
  validates :closing_on, presence: true
  validate :closing_on_must_be_after_opening_on

  def open?
    !closed? && opening_on <= Date.today
  end

  def closed?
    closing_on < Date.today
  end

  def featurable?
    published?
  end

  private

  def closing_on_must_be_after_opening_on
    if closing_on && opening_on && closing_on.to_date <= opening_on.to_date
      errors.add :closing_on,  "must be after the opening on date"
    end
  end

  class << self
    def closed
      where 'closing_on <= :now', now: Time.zone.now
    end

    def open
      where 'closing_on > :now AND opening_on <= :now', now: Time.zone.now
    end

    def upcoming
      where 'opening_on > :now', now: Time.zone.now
    end
  end
end