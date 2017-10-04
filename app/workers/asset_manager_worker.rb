class AssetManagerWorker < WorkerBase
  def perform(file, legacy_url_path)
    Services.asset_manager.create_whitehall_asset(file: file, legacy_url_path: legacy_url_path)
  end
end
