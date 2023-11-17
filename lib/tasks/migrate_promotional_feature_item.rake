desc "Migrate promotional feature items to use assets"
task :migrate_promotional_feature_item, %i[start_id end_id] => :environment do |_, args|
  puts "Migrating promotional feature item start!"
  start_id = args[:start_id]
  end_id = args[:end_id]

  promotional_feature_items = PromotionalFeatureItem.where(id: start_id..end_id).where("image is not null")
  puts "Number of promotional feature items found: #{promotional_feature_items.count}"
  puts "Creating Asset for promotional feature items from #{start_id} to #{end_id}"

  count = 0
  asset_counter = 0
  assetable_type = PromotionalFeatureItem.to_s

  promotional_feature_items.each do |promotional_feature_item|
    # Ensure we do not replay the same migration
    next if promotional_feature_item.assets.count == 7

    all_variants = promotional_feature_item.image.versions.keys.push(:original)

    all_variants.each do |variant|
      path = variant == :original ? promotional_feature_item.image.path : promotional_feature_item.image.versions[variant].path
      puts "Creating Asset for path #{path}"
      asset_counter += 1 if save_asset(promotional_feature_item, assetable_type, variant, path)
    end

    count += 1
  end

  puts "Created assets for #{count} promotional feature items"
  puts "Created asset counter #{asset_counter}"
  puts "Migrating promotional feature item finish!"
end

def save_asset(assetable, assetable_type, variant, path)
  asset_info = get_asset_data(path)
  save_asset_id_to_assets(assetable.id, assetable_type, Asset.variants[variant], asset_info[:asset_manager_id], asset_info[:filename])
rescue GdsApi::HTTPNotFound
  puts "#{assetable_type} of id##{assetable.id} - could not find asset variant :#{variant} at path #{path}"

  false
end

def asset_manager
  Services.asset_manager
end

def get_asset_data(legacy_url_path)
  asset_info = {}
  path = legacy_url_path.sub(/^\//, "")
  response_hash = asset_manager.whitehall_asset(path).to_hash
  asset_info[:asset_manager_id] = get_asset_id(response_hash)
  asset_info[:filename] = get_filename(response_hash)

  asset_info
end

def get_filename(response)
  response["name"]
end

def get_asset_id(response)
  url = response["id"]
  url[/\/assets\/(.*)/, 1]
end

def save_asset_id_to_assets(assetable_id, assetable_type, variant, asset_manager_id, filename)
  asset = Asset.new(asset_manager_id:, assetable_type:, assetable_id:, variant:, filename:)
  asset.save!
end
