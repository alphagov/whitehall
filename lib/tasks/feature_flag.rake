namespace :feature_flag do
  desc "sets a feature flag"
  task :set, [:key, :value] => :environment do |t, args|
    FeatureFlag.set(args[:key], args[:value])
  end
end
