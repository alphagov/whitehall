
class CreateAssetRelationshipWorker < WorkerBase
  def asset_manager
    Services.asset_manager
  end

  def save_asset_id_to_assets(model_id, version, asset_manager_id)
    asset = Asset.new(asset_manager_id:, attachment_data_id: model_id, version:)
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
    attachment_data = AttachmentData.all
    logger.info "no. of attachment data found: "+attachment_data.count.to_s
    attachment_data.each do |attachment|
      begin
        path = attachment.file.path
        asset_manager_id = get_asset_manager_id(path)
        save_asset_id_to_assets(attachment.id, Asset.versions["original"], asset_manager_id)

        if (attachment.pdf?)
          path = attachment.file.thumbnail.asset_manager_path
          asset_manager_id_for_thumbnail = get_asset_manager_id(attachment.file.thumbnail.asset_manager_path)
          save_asset_id_to_assets(attachment.id, Asset.versions["thumbnail"], asset_manager_id_for_thumbnail)
        end
      rescue GdsApi::HTTPNotFound
          logger.warn "asset attachment id:#{attachment.id.to_s} not found in AM for legacy url path: "+ path
      end
    end
    logger.info("CreateAssetRelationshipWorker finish!")
  end
end
