GovukError.configure do |config|
  config.excluded_exceptions << 'AssetManagerAttachmentReplacementIdUpdateWorker::AssetNotFound'
end
