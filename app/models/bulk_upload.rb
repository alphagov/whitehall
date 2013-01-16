require 'tmpdir'
require 'open3'

class BulkUpload
  class ZipFile
    FILE_LIMIT = 100.megabytes
    extend  ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Conversion

    attr_reader :zip_file, :temp_location

    validates :zip_file, presence: true
    validate :is_a_zip_file
    validate :is_not_too_big

    def persisted?
      false
    end

    def initialize(zip_file)
      @zip_file = zip_file
      store_temporarily
    end

    def temp_dir
      @temp_dir ||= Dir.mktmpdir
    end

    def store_temporarily
      return if @zip_file.nil?
      @temp_location = File.join(self.temp_dir, self.zip_file.original_filename)
      FileUtils.cp(self.zip_file.tempfile, @temp_location)
    end

    def extracted_files
      extracted_files ||=
        extract_contents.
          split(/[\r\n]+/).
          reject { |l| l =~ /\AArchive:/ }.
          map { |f| f.gsub(/\A\s+inflating:\s+/,'').strip }.
          map { |f| [File.basename(f), File.join(self.temp_dir, 'extracted', File.basename(f))] }
    end

    def extract_contents
      @unzip_output ||= `#{Whitehall.system_binaries[:unzip]} -o -d #{File.join(self.temp_dir, 'extracted')} #{self.temp_location}`
    end

    def is_a_zip_file
      unless @zip_file.nil?
        errors.add(:zip_file, 'not a zip file') unless looks_like_a_zip? && is_a_zip?
      end
    end

    def looks_like_a_zip?
      @zip_file.original_filename =~ /\.zip\Z/
    end

    def is_a_zip?
      _,_,errs = Open3.popen3("#{Whitehall.system_binaries[:zipinfo]} -1 #{self.temp_location} > /dev/null")
      errs.read.empty?
    end

    def is_not_too_big
      unless @zip_file.nil?
        size = File.size(self.temp_location)
        errors.add(:zip_file, "is too big at #{size} bytes (maximum is #{FILE_LIMIT} bytes)") if size >= ZipFile::FILE_LIMIT
      end
    end
  end

  class ZipFileToAttachments
    def initialize(zip_file, edition, edition_params)
      @zip_file = zip_file
      @edition = edition
      @edition_params = edition_params
    end

    def manipulate_params!
      remove_attachments_params
      add_params_for_new_attachments
      add_params_to_replace_existing_attachments
    end

    def new_attachments
      new_attachments ||=
        @zip_file.extracted_files.
          reject { |(filename, location)|
            @edition.attachments.any? { |a| filename == a.filename }
          }
    end

    def add_params_for_new_attachments
      new_attachments.each do |filename, location|
        add_edition_attachment_params({
          'attachment_attributes' => {
            'attachment_data_attributes' => {
              'file' => ActionDispatch::Http::UploadedFile.new(filename: filename, tempfile: File.open(location))
            }
          }
        })
      end
    end

    def replacement_attachments
      replacement_attachments ||=
        @zip_file.extracted_files.
          map { |(filename, location)|
            [filename, location, @edition.edition_attachments.detect { |a| filename == a.attachment.filename }]
          }.
          reject { |(filename, location, edition_attachment)| edition_attachment.nil? }
    end

    def add_params_to_replace_existing_attachments
      replacement_attachments.each do |filename, location, edition_attachment|
        add_edition_attachment_params({
          'id' => edition_attachment.id.to_s,
          'attachment_attributes' => {
            'id' => edition_attachment.attachment.id.to_s,
            'attachment_data_attributes' => {
              'file' => ActionDispatch::Http::UploadedFile.new(filename: filename, tempfile: File.open(location)),
              'to_replace_id' => edition_attachment.attachment.attachment_data_id.to_s
            }
          }
        })
      end
    end

    def add_edition_attachment_params(params)
      @edition_params['edition_attachments_attributes'] ||= []
      @edition_params['edition_attachments_attributes'] << params
    end

    def remove_attachments_params
      @edition_params.delete(:edition_attachments_attributes)
    end
  end
end
