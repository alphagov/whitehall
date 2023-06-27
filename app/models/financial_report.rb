class FinancialReport < ApplicationRecord
  belongs_to :organisation

  validates :organisation_id, presence: true
  validates :year, presence: true
  validates :year, uniqueness: { scope: :organisation_id }
  validates :year, numericality: { only_integer: true, allow_blank: true }
  # We allow nil because data suggests some organisations are missing some data, 0 would be inaccurate in these cases
  validates :spending, numericality: { only_integer: true }, allow_nil: true
  validates :funding, numericality: { only_integer: true }, allow_nil: true
end
