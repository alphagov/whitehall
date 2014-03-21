class StatisticsAnnouncementDate < ActiveRecord::Base
  PRECISION = { exact: 0, one_month: 1, two_month: 2 }

  belongs_to :statistics_announcement

  validates :release_date, presence: true
  validates :precision, presence: true, inclusion: { in: PRECISION.values }

  def display_date
    case precision
    when PRECISION[:exact]
      release_date.to_s(:long_ordinal)
    when PRECISION[:one_month]
      release_date.to_s(:one_month_precision)
    when PRECISION[:two_month]
      release_date.to_s(:two_month_precision)
    end
  end
end
