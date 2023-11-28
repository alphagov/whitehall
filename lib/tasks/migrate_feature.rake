desc "Migrate feature to use FeaturedImageData with assets"
task :migrate_feature, %i[start_id end_id] => :environment do |_, args|
  puts "Migrating feature start!"
  start_id = args[:start_id]
  end_id = args[:end_id]

  features = Feature.where(id: start_id..end_id).where("carrierwave_image is not null")
  puts "Number of features found: #{features.count}"
  puts "Creating Asset for features from #{start_id} to #{end_id}"

  count = 0
  asset_counter = 0
  assetable_type = FeaturedImageData.to_s

  features.each do |feature|
    # Ensure we do not replay the same migration
    next if feature.image_new

    all_variants = feature.image.versions.keys.push(:original)
    assetable = FeaturedImageData.create!(
      carrierwave_image: feature.carrierwave_image,
      featured_imageable_type: Feature.to_s,
      featured_imageable_id: feature.id,
    )

    all_variants.each do |variant|
      path = variant == :original ? feature.image.path : feature.image.versions[variant].path
      puts "Creating Asset for path #{path}"
      asset_counter += 1 if save_asset(assetable, assetable_type, variant, path)
    end

    count += 1
  end

  puts "Created assets for #{count} features"
  puts "Created asset counter #{asset_counter}"
  puts "Migrating feature finish!"
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
