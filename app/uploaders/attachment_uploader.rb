# encoding: utf-8

require 'carrierwave/processing/mime_types'

class AttachmentUploader < WhitehallUploader
  include CarrierWave::MimeTypes

  PDF_CONTENT_TYPE = 'application/pdf'
  FALLBACK_THUMBNAIL_PDF = File.expand_path("../../assets/images/pub-cover.png", __FILE__)

  process :set_content_type
  after :retrieve_from_cache, :set_content_type
  before :cache, :validate_zipfile_contents!

  version :thumbnail, if: :pdf? do
    def full_filename(for_file)
      super + ".png"
    end
    def full_original_filename
      super + ".png"
    end
    process :generate_thumbnail
    before :store, :set_correct_content_type
    def set_correct_content_type(ignore_argument)
      @file.content_type = "image/png"
    end
  end

  def generate_thumbnail
    get_first_page_as_png(105,140)
  end

  def pdf?(file)
    file.content_type == PDF_CONTENT_TYPE
  end

  def get_first_page_as_png(width, height)
    output = `#{pdf_thumbnail_command(width, height)}`
    if !$?.success?
      Rails.logger.warn "Error thumbnailing PDF. Exit status: #{$?.exitstatus}; Output: #{output}"
      FileUtils.cp(FALLBACK_THUMBNAIL_PDF, path)
    end
  end

  def pdf_thumbnail_command(width, height)
    %{convert -resize #{width}x#{height} "#{path}[0]" "#{path}" 2>&1}
  end

  def extension_white_list
    %w(pdf csv rtf png jpg doc docx xls xlsx ppt pptx zip)
  end

  class ZipFile
    def initialize(zip_path)
      @zip_path = zip_path
    end

    def filenames
      @filenames ||= `#{Whitehall.system_binaries[:zipinfo]} -1 "#{@zip_path}"`.split(/[\r\n]+/)
    end

    def extensions
      filenames.map do |f|
        if match = f.match(/\.([^\.]+)\Z/)
          match[1]
        else
          nil
        end
      end.compact
    end
  end

  def validate_zipfile_contents!(new_file)
    extension = new_file.extension.to_s
    return unless extension == 'zip'
    present_extensions = ZipFile.new(new_file.path).extensions.uniq
    whitelist = extension_white_list - ['zip']
    illegal_extensions = present_extensions - whitelist
    if illegal_extensions.any?
      raise CarrierWave::IntegrityError, "You are not allowed to upload a zip file containing #{illegal_extensions.join(", ")} files, allowed types: #{extension_white_list.inspect}"
    end
  end


end
