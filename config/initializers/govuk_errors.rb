GovukError.configure do |config|
  config.excluded_exceptions += [
    "AssetManagerAttachmentSetUploadedToWorker::AttachmentDataNotFoundTransient",
    "Redis::CannotConnectError",
  ]

  config.data_sync_excluded_exceptions += [
    "ActiveRecord::Deadlocked",
    "Mysql2::Error",
  ]
end
