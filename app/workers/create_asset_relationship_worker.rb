class CreateAssetRelationshipWorker < WorkerBase
  def perform(start_id, end_id)
    logger.info("CreateAssetRelationshipWorker start!")
    assetable_type = AttachmentData
    assetables = assetable_type.where(id: start_id..end_id)
    logger.info "Number of #{assetable_type} found: #{assetables.count}"
    logger.info "Creating Asset for records from #{start_id} to #{end_id}"

    count = 0
    asset_counter = 0
    assetables.each do |assetable|
      assetable.use_non_legacy_endpoints = true
      assetable.save!
      begin
        path = save_asset_original(assetable, assetable_type.to_s)
        asset_counter += 1
      rescue GdsApi::HTTPNotFound
        logger.warn "#{assetable_type} with id:#{assetable.id} for original asset is not found in AM for legacy url path: #{path}"
      end

      if assetable.pdf?
        begin
          path = save_asset_thumbnail(assetable, assetable_type.to_s)
          asset_counter += 1
        rescue GdsApi::HTTPNotFound
          logger.warn "#{assetable_type} with id:#{assetable.id} for thumbnail asset is not found in AM for legacy url path: #{path}"
        end
      end

      count += 1
    end
    logger.info("Created assets for #{count} assetable")
    logger.info("Created asset counter #{asset_counter}")
    logger.info("CreateAssetRelationshipWorker finish!")
  end

private

  def asset_manager
    Services.asset_manager
  end

  def save_asset_id_to_assets(assetable_id, assetable_type, variant, asset_manager_id, filename)
    asset = Asset.new(asset_manager_id:, assetable_type:, assetable_id:, variant:, filename:)
    asset.save!
  end

  def get_asset_data(legacy_url_path)
    asset_info = []
    path = legacy_url_path.sub(/^\//, "")
    response_hash = asset_manager.whitehall_asset(path)
    asset_manager_id = response_hash["id"]
    asset_info << asset_manager_id[/\/assets\/(.*)/, 1]
    asset_info << get_filename(response_hash)
  end

  def save_asset_thumbnail(attachment, assetable_type)
    path = attachment.file.thumbnail.asset_manager_path
    asset_info = get_asset_data(path)

    save_asset_id_to_assets(attachment.id, assetable_type, Asset.variants["thumbnail"], asset_info[0], asset_info[1])
    path
  end

  def save_asset_original(attachment, assetable_type)
    path = attachment.file.path
    asset_info = get_asset_data(path)
    save_asset_id_to_assets(attachment.id, assetable_type, Asset.variants["original"], asset_info[0], asset_info[1])
    path
  end

  def get_filename(response)
    attributes = response.to_hash
    attributes["name"]
  end
end
