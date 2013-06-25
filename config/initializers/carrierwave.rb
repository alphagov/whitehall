require 'whitehall/quarantined_file_storage'

CarrierWave.configure do |config|
  config.storage_engines[:quarantined_file] = 'Whitehall::QuarantinedFileStorage'
  config.storage Whitehall::QuarantinedFileStorage
  config.enable_processing = false if Rails.env.test?
end
