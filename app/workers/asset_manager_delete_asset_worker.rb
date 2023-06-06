class AssetManagerDeleteAssetWorker < WorkerBase
  sidekiq_options queue: "asset_manager"

  def perform(legacy_url_path)
    logger.info "[AssetManagerDeleteAssetWorker]  govuk_request_id: #{GdsApi::GovukHeaders.headers[:govuk_request_id]} legacy_url_path: #{legacy_url_path}"
    AssetManager::AssetDeleter.call(legacy_url_path)
  end
end
