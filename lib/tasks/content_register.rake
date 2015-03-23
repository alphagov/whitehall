namespace :content_register do
  desc "registers all instances of `model_class` with the content register"
  task :register, [:model_class] => :environment do |_, args|
    klass = args[:model_class].constantize
    ContentRegisterer.new(klass.all, Logger.new(STDOUT)).register!
  end
end
