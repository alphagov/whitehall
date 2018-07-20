GovukError.configure do |config|
  config.excluded_exceptions << 'AssetManagerAttachmentSetUploadedToWorker::AttachmentDataNotFoundTransient'
end
