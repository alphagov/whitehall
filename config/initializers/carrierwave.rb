require "whitehall/asset_manager_storage"
require "carrier_wave/sanitized_file"

CarrierWave.configure do |config|
  config.storage_engines[:asset_manager] = "Whitehall::AssetManagerStorage"
  config.storage Whitehall::AssetManagerStorage
  config.enable_processing = false if Rails.env.test?
  config.cache_dir = if !ENV.fetch("CARRIERWAVE_CACHE_DIR", "").empty?
                       ENV["CARRIERWAVE_CACHE_DIR"]
                     else
                       Rails.root.join "carrierwave-tmp"
                     end
  config.cache_storage = :file
  config.validate_integrity = false
  config.validate_processing = false
end
