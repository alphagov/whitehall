require 'whitehall/carrier_wave/sanitized_file'

class Whitehall::QuarantinedFileStorage < CarrierWave::Storage::Abstract
  def store!(file)
    path = ::File.expand_path(uploader.store_path, uploader.incoming_root)
    file.copy_to(path, uploader.permissions)
  end

  def retrieve!(identifier)
    path = ::File.expand_path(uploader.store_path(identifier), Whitehall.clean_uploads_root)
    CarrierWave::SanitizedFile.new(path)
  end
end
