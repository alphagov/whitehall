class Whitehall::QuarantinedFileStorage < CarrierWave::Storage::Abstract
  def store!(file)
    path = ::File.expand_path(uploader.store_path, uploader.incoming_root)
    file.copy_to(path, uploader.permissions)
  end

  def retrieve!(identifier)
    path = ::File.expand_path(uploader.store_path(identifier), uploader.clean_root)
    CarrierWave::SanitizedFile.new(path)
  end

  CarrierWave::Uploader::Base.add_config :incoming_root
  CarrierWave::Uploader::Base.add_config :clean_root

  CarrierWave.configure do |config|
    config.storage_engines[:quarantined_file] = self.name
  end
end
