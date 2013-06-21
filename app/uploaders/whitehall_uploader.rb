require 'carrierwave/processing/mime_types'

class WhitehallUploader < CarrierWave::Uploader::Base
  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Returns path to the file, relative to the [incoming|clean] root.
  def relative_path
    store_path(File.basename(path))
  end

  def clean_path
    File.join(Whitehall.clean_upload_path, relative_path)
  end
end
