desc "Create disabled subscriber lists in email-alert-api from govuk-delivery CSV export"
task :url_to_subscriber_list_criteria, [:csv_path, :perform_migration] => :environment do |_t, args|
  migrator = UrlToSubscriberListCriteriaMigration.new(args[:csv_path], args[:perform_migration])

  migrator.run
  migrator.report
end
