class AssetManagerUpdateAssetWorker < WorkerBase
  def perform(legacy_url_path, draft)
    gds_api_response = Services.asset_manager.whitehall_asset(legacy_url_path)
    asset_url = gds_api_response['id']
    asset_id = asset_url[/\/assets\/(.*)/, 1]

    # TODO: We could optimise this by working out whether the draft status
    # has changed and only update it in the Asset Manager if it has.
    Services.asset_manager.update_asset(asset_id, draft: draft)
  end
end
