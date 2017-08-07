namespace :email_topics do
  task :check, [:content_id] => :environment do |_task, args|
    content_id = args.content_id
    EmailTopicChecker.check(content_id)
  end
end
