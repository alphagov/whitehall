desc "Migrate topical events to use FeaturedImageData with assets"
task :migrate_topical_events, %i[start_id end_id] => :environment do |_, args|
  puts "Migrating topical events start!"
  start_id = args[:start_id]
  end_id = args[:end_id]

  topical_events = TopicalEvent.where(id: start_id..end_id).where("carrierwave_image is not null and featured_image_data_id is null")
  puts "Number of topical events found: #{topical_events.count}"
  puts "Creating Asset for topical events records from #{start_id} to #{end_id}"

  count = 0
  asset_counter = 0
  assetable_type = FeaturedImageData.to_s

  topical_events.each do |topical_event|
    all_variants = topical_event.logo.versions.keys.push(:original)
    assetable = FeaturedImageData.create!(
      carrierwave_image: topical_event.carrierwave_image,
      featured_imageable_type: TopicalEvent.to_s,
      featured_imageable_id: topical_event.id,
    )

    all_variants.each do |variant|
      path = variant == :original ? topical_event.logo.path : topical_event.logo.versions[variant].path
      puts "Creating Asset for path #{path}"
      asset_counter += 1 if save_asset(assetable, assetable_type, variant, path)
    end

    count += 1
  end

  puts "Created assets for #{count} topical events"
  puts "Created asset counter #{asset_counter}"
  puts "Migrating topical events finish!"
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
