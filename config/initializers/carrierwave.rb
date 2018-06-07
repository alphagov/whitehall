require 'whitehall/asset_manager_storage'
require 'whitehall/carrier_wave/sanitized_file'

CarrierWave.configure do |config|
  config.storage_engines[:asset_manager] = 'Whitehall::AssetManagerStorage'
  config.storage Whitehall::AssetManagerStorage
  config.enable_processing = false if Rails.env.test?
  config.cache_dir = Rails.root.join "carrierwave-tmp"
  config.validate_integrity = false
  config.validate_processing = false
end
