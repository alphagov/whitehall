class ReviewReminder < ApplicationRecord
  belongs_to :document
  belongs_to :creator, class_name: "User"

  scope :reminder_due, lambda {
    where(review_at: ..Time.zone.today, reminder_sent_at: nil)
      .joins(document: :latest_edition)
      .where.not(document: { editions: { first_published_at: nil } })
  }

  validates :document, :creator, :review_at, :email_address, presence: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP, if: -> { email_address.present? } }
  validate :review_date_cannot_be_in_the_past, if: -> { review_at.present? }

  before_update :reset_reminder_sent_at, if: :review_at_changed?

  def review_due?
    Time.zone.today >= review_at
  end

private

  def review_date_cannot_be_in_the_past
    if review_at < Time.zone.today
      errors.add(:review_at, "can't be in the past")
    end
  end

  def reset_reminder_sent_at
    self.reminder_sent_at = nil
  end
end
