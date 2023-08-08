desc "Send review reminder emails for when the review_at date has passed"
task send_review_reminders: :environment do
  ReviewReminder.reminder_due.pluck(:id).each do |id|
    ReviewReminderNotifierWorker.perform_async(id)
  end
end
