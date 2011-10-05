# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(pdf)
  end
end