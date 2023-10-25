desc "Create Asset relationship for Featured Image Data"

task :create_asset_relationship_for_featured_image_data, %i[start_id end_id] => :environment do |_, args|
  CreateAssetRelationshipForFeaturedImageDataWorker.perform_async(args[:start_id].to_i, args[:end_id].to_i)
end
