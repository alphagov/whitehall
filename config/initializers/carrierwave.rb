CarrierWave.configure do |config|
  if Whitehall.use_s3?
    config.storage :fog
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Whitehall.aws_access_key_id,
      aws_secret_access_key: Whitehall.aws_secret_access_key,
      region: 'eu-west-1'
    }
    config.fog_directory  = "whitehall-frontend-#{Whitehall.platform}"
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}
  else
    config.storage :file
    config.enable_processing = false if Rails.env.test?
  end
end