module Edition::HasOpeningAndClosingDates
  extend ActiveSupport::Concern

  included do
    validates :opening_at, presence: true, unless: ->(record) { record.can_have_some_invalid_data? }
    validates :closing_at, presence: true, unless: ->(record) { record.can_have_some_invalid_data? }
    validates :closing_at, comparison: { greater_than: :opening_at, message: "must be after the opening on date" }, if: proc { |record| record.opening_at && record.closing_at }

    scope :closed, -> { where("closing_at < ?", Time.zone.now) }
    scope :closed_at_or_after, ->(time) { closed.where("closing_at >= ?", time) }
    scope :closed_at_or_within_24_hours_of,
          lambda { |time|
            closed.where("? < closing_at AND closing_at <= ?", time - 24.hours, time)
          }
    scope :open, -> { where("closing_at >= ? AND opening_at <= ?", Time.zone.now, Time.zone.now) }
    scope :opened_at_or_after, ->(time) { open.where("opening_at >= ?", time) }
    scope :upcoming, -> { where("opening_at > ?", Time.zone.now) }
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
end
