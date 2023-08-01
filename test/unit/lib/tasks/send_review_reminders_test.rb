require "test_helper"
require "rake"

class SendReviewRemindersTest < ActiveSupport::TestCase
  teardown do
    Sidekiq::Worker.clear_all
  end

  test "it queues a ReviewReminderNotifierWorker for every reminder that is due" do
    reminders = [
      due = build(:review_reminder, :reminder_due),
      overdue = build(:review_reminder, :reminder_due, review_at: 1.week.ago),
      already_sent = build(:review_reminder, :reminder_sent),
      not_due_yet = build(:review_reminder, :not_due_yet),
    ]

    # Bypass validation so review_at dates in the past can be saved
    reminders.each { |r| r.save!(validate: false) }

    ReviewReminderNotifierWorker.expects(:perform_async).with(due.id).once
    ReviewReminderNotifierWorker.expects(:perform_async).with(overdue.id).once
    ReviewReminderNotifierWorker.expects(:perform_async).with(already_sent.id).never
    ReviewReminderNotifierWorker.expects(:perform_async).with(not_due_yet.id).never

    Rake.application.invoke_task "send_review_reminders"
  end
end
