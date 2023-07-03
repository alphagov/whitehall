class CreateAssetRelationshipWorker < WorkerBase
  def asset_manager
    Services.asset_manager
  end

  def save_asset_id_to_assets(model_id, variant, asset_manager_id)
    asset = Asset.new(asset_manager_id:, attachment_data_id: model_id, variant:)
    asset.save!
  end

  def get_asset_manager_id(legacy_url_path)
    path = legacy_url_path.sub(/^\//, "")
    response_hash = asset_manager.whitehall_asset(path)
    asset_manager_id = response_hash["id"]
    asset_manager_id[/\/assets\/(.*)/, 1]
  end

  def perform
    logger.info("CreateAssetRelationshipWorker start!")
    counter_start = 2000
    counter_end = 10000
    attachment_data = AttachmentData.where(id:counter_start..counter_end)
    logger.info "no. of attachment data found: #{attachment_data.count.to_s}"
    logger.info "Creating Asset for #{counter_end} records  "

    count = counter_start
    attachment_data.each do |attachment|
      break if count == counter_end

      begin
        path = save_asset_original(attachment)

        if attachment.pdf?
          path = save_asset_thumbnail(attachment)
        end

        count += 1
      rescue GdsApi::HTTPNotFound
        logger.warn "asset attachment id:#{attachment.id.to_s} not found in AM for legacy url path: #{path}"
      end
    end
    logger.info("Created #{count} assets")
    logger.info("CreateAssetRelationshipWorker finish!")
  end

  private

  def save_asset_thumbnail(attachment)
    path = attachment.file.thumbnail.asset_manager_path
    asset_manager_id_for_thumbnail = get_asset_manager_id(attachment.file.thumbnail.asset_manager_path)
    save_asset_id_to_assets(attachment.id, Asset.variants["thumbnail"], asset_manager_id_for_thumbnail)
    path
  end

  def save_asset_original(attachment)
    path = attachment.file.path
    asset_manager_id = get_asset_manager_id(path)
    save_asset_id_to_assets(attachment.id, Asset.variants["original"], asset_manager_id)
    path
  end
end
