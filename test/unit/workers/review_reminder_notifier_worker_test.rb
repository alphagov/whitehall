require "test_helper"

class ReviewReminderNotifierWorkerTest < ActiveSupport::TestCase
  setup do
    document = create(:document)
    @review_reminder = create(:review_reminder, document:)
    @email_address = @review_reminder.email_address
    @editon = create(:edition, document:)
  end

  test "calls MailNotifications#review_reminder and updates reminder_sent_at to now when reminder_sent_at is nil" do
    Timecop.freeze do
      MailNotifications
        .expects(:review_reminder)
        .with(@editon, recipient_address: @email_address)
        .returns(mailer = mock)

      mailer.expects(:deliver_now)

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
