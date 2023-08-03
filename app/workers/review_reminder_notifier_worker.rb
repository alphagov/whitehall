class ReviewReminderNotifierWorker < WorkerBase
  def perform(id)
    review_reminder = ReviewReminder.find(id)
    return if review_reminder.reminder_sent_at.present?

    edition = review_reminder.document.latest_edition
    email_address = review_reminder.email_address

    ActiveRecord::Base.transaction do
      MailNotifications.review_reminder(
        edition,
        recipient_address: email_address,
      ).deliver_now

      review_reminder.update_columns(reminder_sent_at: Time.zone.now)
    end
  end
end
