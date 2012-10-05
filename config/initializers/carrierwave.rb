CarrierWave.configure do |config|
  case Whitehall.asset_storage_mechanism
  when :s3
    config.storage :fog
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Whitehall.aws_access_key_id,
      aws_secret_access_key: Whitehall.aws_secret_access_key,
      region: 'eu-west-1'
    }
    config.fog_directory  = "whitehall-frontend-#{Whitehall.platform}"
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
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