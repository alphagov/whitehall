desc "Create Asset relationship for AttachmentData"

task :create_asset_relationship, %i[start_id end_id] => :environment do |_, args|
  CreateAssetRelationshipWorker.perform_async(args[:start_id].to_i, args[:end_id].to_i)
end
