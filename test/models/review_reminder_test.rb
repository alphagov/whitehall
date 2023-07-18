require "test_helper"

class ReviewReminderTest < ActiveSupport::TestCase
  test "is associated with a document" do
    document = build(:document)
    reminder = build(:review_reminder, document:)

    assert_equal reminder.document, document
  end

  test "is associated with a creator" do
    creator = build(:user)
    reminder = build(:review_reminder, creator:)

    assert_equal reminder.creator, creator
  end

  test "is invalid without a creator" do
    reminder = build(:review_reminder, creator: nil)
    assert_not reminder.valid?
  end

  test "is invalid without a document" do
    reminder = build(:review_reminder, document: nil)
    assert_not reminder.valid?
  end

  test "is invalid without a review_at datetime" do
    reminder = build(:review_reminder, review_at: nil)
    assert_not reminder.valid?
  end

  test "is invalid if review_at is in the past" do
    reminder = build(:review_reminder, review_at: 1.day.ago)
    assert_not reminder.valid?
  end

  test "is invalid without an email_address" do
    reminder = build(:review_reminder, email_address: nil)
    assert_not reminder.valid?
  end

  test "is invalid with an invalid email_address" do
    reminder = build(:review_reminder, email_address: "not a real email @ address . com")
    assert_not reminder.valid?
  end

  test "#review_due? returns true when review_at is in the past" do
    reminder = build(:review_reminder, review_at: 1.day.ago)
    assert reminder.review_due?
  end

  test "#review_due? returns true when review_at is today" do
    reminder = build(:review_reminder, review_at: Time.zone.today)
    assert reminder.review_due?
  end

  test "#review_due? returns false when review_at is in the future" do
    reminder = build(:review_reminder, review_at: 1.day.from_now)
    assert_not reminder.review_due?
  end

  test "it resets reminder_sent_at when the review_at date is changed" do
    reminder = create(:review_reminder, :with_reminder_sent_at)

    reminder.update!(review_at: Time.zone.now + 10.days)

    assert_nil reminder.reload.reminder_sent_at
  end
end
