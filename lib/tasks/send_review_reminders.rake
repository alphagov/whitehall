require_relative "confirm_rake_task"

desc "Send review reminder emails for when the review_at date has passed"
task send_review_reminders: :environment do
  ids = ReviewReminder.reminder_due.pluck(:id)
  puts "Review reminders would be sent for the following IDs:"
  puts ids.inspect

  unless Confirm.ask("Proceed to send review reminders? (yes/no)")
    puts "Sending aborted"
    exit 1
  end

  ids.each do |id|
    ReviewReminderNotifierWorker.perform_async(id)
  end
end
