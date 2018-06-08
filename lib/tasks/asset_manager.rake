namespace :asset_manager do
  task generate_missing_thumbnails: :environment do
    [332963, 310979, 199066, 318696, 311266, 321710, 199068, 326576, 69897, 417180, 371318, 501885, 418558].each do |id|
      begin
        attachment_data = AttachmentData.find(id)
        attachment_data.file.recreate_versions!
      rescue ActiveRecord::RecordNotFound => e
        puts e
      end
    end
  end

  task dump: :environment do
    AssetAudit.dump
  end

  task :audit_check_status, %i(email app_domain filename) => :environment do |_, args|
    AssetAudit.check_status(args[:email], args[:app_domain], args[:filename])
  end
end
