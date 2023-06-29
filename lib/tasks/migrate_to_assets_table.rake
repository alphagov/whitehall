desc "Create Asset relationship for AttachmentData"

task create_asset_relationship: :environment do
  CreateAssetRelationshipWorker.perform_async
end