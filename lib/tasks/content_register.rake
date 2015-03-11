namespace :content_register do
  desc "registers all organisations with the content register"
  task :organisations => :environment do
    ContentRegisterer.new(Organisation.all, Logger.new(STDOUT)).register!
  end

  desc "register all people with the content register"
  task :people => :environment do
    ContentRegisterer.new(Person.all, Logger.new(STDOUT)).register!
  end
end
