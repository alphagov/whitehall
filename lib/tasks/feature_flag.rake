namespace :feature_flag do
  desc "Creates a feature flag"
  task :create, %i[key] => :environment do |_t, args|
    raise "Please specify a feature flag key." if args[:key].blank?

    FeatureFlag.create(key: args[:key])

    puts "Succesfully created feature flag with key: #{args[:key]}."
  end

  desc "Deletes a feature flag"
  task :delete, %i[key] => :environment do |_t, args|
    raise "Please specify a feature flag key" if args[:key].blank?

    flag = FeatureFlag.find_by(key: args[:key])

    raise "Could not find feature flag with key: #{args[:key]}." if flag.nil?

    flag.delete

    puts "Succesfully deleted feature flag with key: #{args[:key]}."
  end

  desc "Enables feature flag"
  task :enable, %i[key] => :environment do |_t, args|
    raise "Please specify a feature flag key" if args[:key].blank?

    FeatureFlag.set(args[:key], true)

    puts "Succesfully enabled feature flag with key: #{args[:key]}."
  end

  desc "Disables feature flag"
  task :disable, %i[key] => :environment do |_t, args|
    raise "Please specify a feature flag key" if args[:key].blank?

    FeatureFlag.set(args[:key], false)

    puts "Succesfully disabled feature flag with key: #{args[:key]}."
  end
end
