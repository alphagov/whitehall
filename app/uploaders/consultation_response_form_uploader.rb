# encoding: utf-8

class ConsultationResponseFormUploader < CarrierWave::Uploader::Base
  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(pdf csv rtf doc docx xls xlsx)
  end
end
