GovukError.configure do |config|
  config.excluded_exceptions += [
    "Redis::CannotConnectError",
  ]

  config.data_sync_excluded_exceptions += [
    "ActiveRecord::Deadlocked",
    "Mysql2::Error",
  ]
end
