# encoding: utf-8

require 'carrierwave/processing/mime_types'

class AttachmentUploader < CarrierWave::Uploader::Base

  include CarrierWave::MimeTypes
  process :set_content_type

  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(pdf)
  end
end