class ReviewReminder < ApplicationRecord
  belongs_to :document
  belongs_to :creator, class_name: "User"

  validates :document, :creator, :review_at, :email_address, presence: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP, if: -> { email_address.present? } }
  validate :review_date_cannot_be_in_the_past, if: -> { review_at.present? }

private

  def review_date_cannot_be_in_the_past
    if review_at < Time.zone.today
      errors.add(:review_at, "can't be in the past")
    end
  end
end
