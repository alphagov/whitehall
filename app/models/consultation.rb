class Consultation < Document
  validates :opening_on, presence: true
  validates :closing_on, presence: true
end