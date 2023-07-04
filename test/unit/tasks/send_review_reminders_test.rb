require "test_helper"
require "rake"

class ResluggingTest < ActiveSupport::TestCase
  teardown do
    Sidekiq::Worker.clear_all
  end

  test "it calls the ReviewReminderNotifierWorker with the correct review_reminders" do
    document1 = create(:document)
    create(:published_edition, document: document1)
    review_reminder_to_be_sent = build(:review_reminder, document: document1, review_at: Time.zone.now - 1.day)
    review_reminder_to_be_sent.save!(validate: false)

    document2 = create(:document)
    create(:published_edition, document: document2)
    review_reminder_with_future_review_at = create(:review_reminder, document: document2, review_at: Time.zone.now + 1.day)

    document3 = create(:document)
    create(:published_edition, document: document3)
    review_reminder_with_sent_reminder = create(:review_reminder, :with_reminder_sent_at, document: document3)

    document4 = create(:document)
    create(:edition, document: document4)
    review_reminder_with_no_published_editions = build(:review_reminder, document: document4, review_at: Time.zone.now - 1.day)
    review_reminder_with_no_published_editions.save!(validate: false)

    ReviewReminderNotifierWorker.expects(:perform_async).with(review_reminder_to_be_sent.id.to_s).once
    ReviewReminderNotifierWorker.expects(:perform_async).with(review_reminder_with_future_review_at.id.to_s).never
    ReviewReminderNotifierWorker.expects(:perform_async).with(review_reminder_with_sent_reminder.id.to_s).never
    ReviewReminderNotifierWorker.expects(:perform_async).with(review_reminder_with_no_published_editions.id.to_s).never

    Rake.application.invoke_task "send_review_reminders"
  end
end
