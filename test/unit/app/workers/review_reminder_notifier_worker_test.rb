require "test_helper"

class ReviewReminderNotifierWorkerTest < ActiveSupport::TestCase
  test "calls MailNotifications#review_reminder and updates reminder_sent_at" do
    reminder = create(:review_reminder, :reminder_due)
    edition = reminder.document.latest_edition
    recipient_address = reminder.email_address

    MailNotifications
      .expects(:review_reminder)
      .with(edition, recipient_address:)
      .returns(mailer = mock)

    mailer.expects(:deliver_now)

    # Freeze time so we can assert against the current time without it changing
    Timecop.freeze do
      ReviewReminderNotifierWorker.new.perform(reminder.id)

      assert_equal Time.zone.now, reminder.reload.reminder_sent_at
    end
  end

  test "does nothing if reminder does not need to be sent" do
    MailNotifications.expects(:review_reminder).never

    not_due_yet = create(:review_reminder, :not_due_yet)
    ReviewReminderNotifierWorker.new.perform(not_due_yet.id)

    already_sent = create(:review_reminder, :reminder_sent)
    ReviewReminderNotifierWorker.new.perform(already_sent.id)
  end
end
