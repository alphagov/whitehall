desc "Migrate worldwide organisations to use FeaturedImageData with assets"
task :migrate_worldwide_organisations, %i[start_id end_id] => :environment do |_, args|
  puts "Migrating worldwide organisations start!"
  start_id = args[:start_id]
  end_id = args[:end_id]

  worldwide_organisations = WorldwideOrganisation.where(id: start_id..end_id).where("default_news_organisation_image_data_id is not null")
  puts "Number of worldwide organisations found: #{worldwide_organisations.count}"
  puts "Creating Asset for worldwide organisations records from #{start_id} to #{end_id}"

  count = 0
  asset_counter = 0
  assetable_type = FeaturedImageData.to_s

  worldwide_organisations.each do |worldwide_organisation|
    next if worldwide_organisation.default_news_image_new.present?

    all_variants = %i[original s960 s712 s630 s465 s300 s216]
    assetable = FeaturedImageData.create!(
      carrierwave_image: worldwide_organisation.default_news_image.carrierwave_image,
      featured_imageable_type: WorldwideOrganisation.to_s,
      featured_imageable_id: worldwide_organisation.id,
    )

    all_variants.each do |variant|
      path = variant == :original ? worldwide_organisation.default_news_image.file.path : worldwide_organisation.default_news_image.file.versions[variant].path
      puts "Creating Asset for path #{path}"
      asset_counter += 1 if save_asset(assetable, assetable_type, variant, path)
    end

    count += 1
  end

  puts "Created assets for #{count} worldwide organisations"
  puts "Created asset counter #{asset_counter}"
  puts "Migrating worldwide organisations finish!"
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
