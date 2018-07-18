GovukError.configure do |config|
  config.excluded_exceptions += [
    "AssetManagerAttachmentReplacementIdUpdateWorker::AssetNotFound",
    "AttachmentNotYetUploadedError",
  ]
end
