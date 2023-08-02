require "test_helper"

class ReviewReminderNotifierWorkerTest < ActiveSupport::TestCase
  setup do
    @edition = create(:edition)
    @review_reminder = create(:review_reminder, document: @edition.document)
  end

  test "calls MailNotifications#review_reminder and updates reminder_sent_at to now when reminder_sent_at is nil" do
    MailNotifications
      .expects(:review_reminder)
      .with(@edition, recipient_address: @review_reminder.email_address)
      .returns(mailer = mock)

    mailer.expects(:deliver_now)

    # Freeze time so we can assert against the current time without it changing
    Timecop.freeze do
      ReviewReminderNotifierWorker.new.perform(@review_reminder.id)

      assert_equal Time.zone.now, @review_reminder.reload.reminder_sent_at
    end
  end

  test "does not call MailNotifications#review_reminder or update reminder_sent_at when reminder_sent_at is present" do
    reminder_sent_at = Time.zone.now
    @review_reminder.update!(reminder_sent_at:)

    Timecop.travel(1.day.from_now) do
      MailNotifications
        .expects(:review_reminder)
        .never

      ReviewReminderNotifierWorker.new.perform(@review_reminder.id)

      assert_equal reminder_sent_at, @review_reminder.reload.reminder_sent_at
    end
  end
end
