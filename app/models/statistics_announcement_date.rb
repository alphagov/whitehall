class StatisticsAnnouncementDate < ApplicationRecord
  PRECISION = { exact: 0, one_month: 1, two_month: 2 }.freeze

  belongs_to :statistics_announcement, touch: true
  belongs_to :creator, class_name: "User"

  after_save :update_statistics_announcement_current_release_date, if: -> { statistics_announcement.present? }

  validates :release_date, presence: true
  validates :precision, presence: true, inclusion: { in: PRECISION.values }
  validate :confirmed_date_must_be_exact

  def display_date
    case precision
    when PRECISION[:exact]
      release_date.to_fs(:date_with_time)
    when PRECISION[:one_month]
      release_date.to_fs(:one_month_precision)
    when PRECISION[:two_month]
      release_date.to_fs(:two_month_precision)
    end
  end

private

  def update_statistics_announcement_current_release_date
    statistics_announcement.update_current_release_date
  end

  def confirmed_date_must_be_exact
    if confirmed? && precision != PRECISION[:exact]
      errors.add(:precision, message: "Must be exact if date is confirmed")
    end
  end
end
