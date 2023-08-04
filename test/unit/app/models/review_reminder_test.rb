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
    reminder = create(:review_reminder, :reminder_sent)

    reminder.update!(review_at: 10.days.from_now)

    assert_nil reminder.reload.reminder_sent_at
  end

  test "#reminder_due? returns true when the reminder email needs to be sent" do
    assert build(:review_reminder, :reminder_due).reminder_due?
  end

  test "#reminder_due? returns false when the reminder email does not need to be sent" do
    assert_not build(:review_reminder, :not_due_yet).reminder_due?
    assert_not build(:review_reminder, :due_but_never_published).reminder_due?
    assert_not build(:review_reminder, :reminder_sent).reminder_due?
  end

  test ".reminder_due scope returns reminders that are due to be sent" do
    reminders = [
      due = build(:review_reminder, :reminder_due),
      overdue = build(:review_reminder, :reminder_due, review_at: 1.week.ago),
      already_sent = build(:review_reminder, :reminder_sent),
      due_but_never_published = build(:review_reminder, :due_but_never_published),
      not_due_yet = build(:review_reminder, :not_due_yet),
    ]

    # Bypass validation so review_at dates in the past can be saved
    reminders.each { |r| r.save!(validate: false) }

    assert_includes ReviewReminder.reminder_due, due
    assert_includes ReviewReminder.reminder_due, overdue
    assert_not_includes ReviewReminder.reminder_due, already_sent
    assert_not_includes ReviewReminder.reminder_due, due_but_never_published
    assert_not_includes ReviewReminder.reminder_due, not_due_yet
  end
end
