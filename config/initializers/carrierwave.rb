require 'whitehall/quarantined_file_storage'

CarrierWave::Uploader::Base.add_config :incoming_root

CarrierWave.configure do |config|
  config.storage_engines[:quarantined_file] = 'Whitehall::QuarantinedFileStorage'
  config.storage Whitehall::QuarantinedFileStorage
  config.incoming_root = File.join(Whitehall.uploads_root, 'incoming-uploads')
  config.enable_processing = false if Rails.env.test?
end
