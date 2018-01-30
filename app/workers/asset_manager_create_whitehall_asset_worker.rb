class AssetManagerCreateWhitehallAssetWorker < WorkerBase
  def perform(file_path, legacy_url_path)
    file = File.open(file_path)
    asset_options = { file: file, legacy_url_path: legacy_url_path }
    asset_options[:draft] = true if legacy_url_path.match?(/attachment_data/)
    Services.asset_manager.create_whitehall_asset(asset_options)
    FileUtils.rm(file)
    FileUtils.rmdir(File.dirname(file))
  end
end
