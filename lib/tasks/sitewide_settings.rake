namespace :sitewide_settings do
  desc "sets a sitewide setting"
  task :set, [:key, :on] => :environment do |t, args|
    SitewideSetting.set(args[:key], args[:on])
  end
end
