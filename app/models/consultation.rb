class Consultation < Document
  validates :opening_on, presence: true
  validates :closing_on, presence: true
  validate :closing_on_must_be_after_opening_on

  private

  def closing_on_must_be_after_opening_on
    if closing_on && opening_on && closing_on.to_date <= opening_on.to_date
      errors.add :closing_on,  "must be after the opening on date"
    end
  end
end