class ReviewReminderNotifierWorker < WorkerBase
  def perform(id)
    review_reminder = ReviewReminder.find(id)
    return unless review_reminder.reminder_due?

    edition = review_reminder.document.latest_edition
    email_address = review_reminder.email_address

    MailNotifications.review_reminder(
      edition,
      recipient_address: email_address,
    ).deliver_now

    review_reminder.reminder_sent!
  end
end
