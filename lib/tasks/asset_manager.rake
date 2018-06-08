namespace :asset_manager do
  task dump: :environment do
    AssetAudit.dump
  end

  task :audit_check_status, %i(email app_domain filename) => :environment do |_, args|
    AssetAudit.check_status(args[:email], args[:app_domain], args[:filename])
  end
end
