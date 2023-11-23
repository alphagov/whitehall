desc "Migrate call for evidence response form data to use assets"
task :migrate_call_for_evidence_response_form_data, %i[start_id end_id] => :environment do |_, args|
  puts "Migrating call for evidence response form data start!"
  start_id = args[:start_id]
  end_id = args[:end_id]

  call_for_evidence_response_form_datas = CallForEvidenceResponseFormData.where(id: start_id..end_id).where("carrierwave_file is not null")
  puts "Number of call for evidence response form data found: #{call_for_evidence_response_form_datas.count}"
  puts "Creating Asset for call for evidence response form data from #{start_id} to #{end_id}"

  count = 0
  asset_counter = 0
  assetable_type = CallForEvidenceResponseFormData.to_s

  call_for_evidence_response_form_datas.each do |call_for_evidence_response_form_data|
    # Ensure we do not replay the same migration
    next if call_for_evidence_response_form_data.assets.count == 1

    variant = :original

    path = call_for_evidence_response_form_data.file.path
    puts "Creating Asset for path #{path}"
    asset_counter += 1 if save_asset(call_for_evidence_response_form_data, assetable_type, variant, path)

    count += 1
  end

  puts "Created assets for #{count} call for evidence response form data"
  puts "Created asset counter #{asset_counter}"
  puts "Migrating call for evidence response form data finish!"
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
