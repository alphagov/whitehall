CarrierWave.configure do |config|
  case Whitehall.asset_storage_mechanism
  when :file
    config.storage :file
    config.enable_processing = false if Rails.env.test?
  when :quarantined_file
    require 'whitehall/quarantined_file_storage'
    config.storage Whitehall::QuarantinedFileStorage
    config.incoming_root = Rails.root.join 'incoming-uploads'
    config.clean_root = Rails.root.join 'public/government/uploads'
  end
end