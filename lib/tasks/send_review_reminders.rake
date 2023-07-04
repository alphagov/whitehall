desc "Send review reminder emails for when the review_at datetime has passed"
task send_review_reminders: :environment do
  ReviewReminder
  .joins(document: :latest_edition)
  .where(reminder_sent_at: nil)
  .where("review_at < ?", Time.zone.today)
  .where.not(document: { editions: { first_published_at: nil } })
  .find_each do |reminder|
    ReviewReminderNotifierWorker.perform_async(reminder.id.to_s)
  end
end
