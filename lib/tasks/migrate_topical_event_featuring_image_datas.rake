desc "Migrate topical event featuring image datas to use FeaturedImageData with assets"
task :migrate_topical_event_featuring_image_datas, %i[start_id end_id] => :environment do |_, args|
  puts "Migrating topical event featurings start!"
  start_id = args[:start_id]
  end_id = args[:end_id]

  topical_event_featuring_image_datas = TopicalEventFeaturingImageData.where(id: start_id..end_id).where("carrierwave_image is not null")
  puts "Number of topical event featuring image datas found: #{topical_event_featuring_image_datas.count}"
  puts "Creating Asset for topical event featuring image data records from #{start_id} to #{end_id}"

  count = 0
  asset_counter = 0

  topical_event_featuring_image_datas.each do |image_data|
    all_variants = image_data.file.versions.keys.push(:original)

    all_variants.each do |variant|
      path = variant == :original ? image_data.file.path : image_data.file.versions[variant].path
      puts "Creating Asset for path #{path}"
      asset_counter += 1 if save_asset(image_data, TopicalEventFeaturingImageData.to_s, variant, path)
    end

    count += 1
  end

  puts "Created assets for #{count} topical event featuring image datas"
  puts "Created asset counter #{asset_counter}"
  puts "Migrating topical event featuring image datas finish!"
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
