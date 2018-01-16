namespace :feature_flag do
  desc "sets a feature flag"
  task :set, %i[key value] => :environment do |_t, args|
    FeatureFlag.set(args[:key], args[:value])
  end
end
