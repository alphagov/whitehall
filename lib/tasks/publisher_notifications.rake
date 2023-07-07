namespace :publisher_notifications do
  desc "Send notifications to publishers. Task is run daily. Check Cron job in Helm Charts."
  task send: :environment do
    ConsultationReminder.send_all
    CallForEvidenceReminder.send_reminder
  end
end
