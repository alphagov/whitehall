Around("@quarantine-files") do |scenario, block|
  CarrierWave.configure do |config|
    config.reset_config
    config.storage Whitehall::QuarantinedFileStorage
    config.incoming_root Rails.root + "test-quarantine"
    config.clean_root Rails.root + "public/system/uploads/attachment/test"
  end

  block.call

  FileUtils.rm_rf(CarrierWave::Uploader::Base.incoming_root)
  FileUtils.rm_rf(CarrierWave::Uploader::Base.clean_root)

  CarrierWave::Uploader::Base.reset_config
  load Rails.root + 'config/initializers/carrierwave.rb'
end
