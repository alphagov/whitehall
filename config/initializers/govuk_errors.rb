GovukError.configure do |config|
  config.excluded_exceptions << 'AssetManager::AttachmentReplacementIdUpdater::AssetNotFound'
end
