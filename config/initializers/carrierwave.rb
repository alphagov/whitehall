require 'whitehall/quarantined_file_storage'

CarrierWave.configure do |config|
  config.storage_engines[:quarantined_file] = 'Whitehall::QuarantinedFileStorage'
  config.storage_engines[:asset_manager] = 'Whitehall::AssetManagerStorage'
  config.storage_engines[:asset_manager_and_file_system] = 'Whitehall::AssetManagerAndQuarantinedFileStorage'
  config.storage Whitehall::QuarantinedFileStorage
  config.enable_processing = false if Rails.env.test?
  config.cache_dir = Rails.root.join "carrierwave-tmp"
  config.validate_integrity = false
  config.validate_processing = false
end
