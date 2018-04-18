namespace :publisher_notifications do
  desc "Send notifications to publishers"
  task send: :environment do
    ConsultationReminder.send_all
  end
end
