desc "Create Asset relationship for AttachmentData"

task :create_asset_relationship, %i[assetable_type start_id end_id] => :environment do |_, args|
  CreateAssetRelationshipWorker.perform_async(args[:assetable_type], args[:start_id].to_i, args[:end_id].to_i)
end
