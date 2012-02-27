# encoding: utf-8

require 'carrierwave/processing/mime_types'

class AttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes

  PDF_CONTENT_TYPE = 'application/pdf'

  process :set_content_type
  after :retrieve_from_cache, :set_content_type

  version :thumbnail, if: :pdf? do
    def full_filename(for_file)
      super + ".png"
    end
    def full_original_filename
      super + ".png"
    end
    process :generate_thumbnail
  end

  def store_dir
    "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def generate_thumbnail
    get_first_page_as_png(105,140)
  end

  def pdf?(file)
    file.content_type == PDF_CONTENT_TYPE
  end

  def get_first_page_as_png(width, height)
    output = `convert -resize #{width}x#{height} "#{path}[0]" "#{path}" 2>&1`
    unless $?.success?
      Rails.logger.error "Error thumbnailing PDF. Output: #{output}; Exit status: #{$?.exitstatus}"
    end
  end

  def extension_white_list
    %w(pdf csv rtf png jpg doc docx xls xlsx ppt pptx)
  end
end