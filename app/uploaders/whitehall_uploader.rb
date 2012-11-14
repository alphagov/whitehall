require 'carrierwave/processing/mime_types'

class WhitehallUploader < CarrierWave::Uploader::Base
  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
end