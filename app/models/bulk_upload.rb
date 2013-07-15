require 'tmpdir'
require 'open3'

class BulkUpload
  class ZipFile
    class << self
      attr_accessor :default_root_directory
    end

    extend  ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Conversion

    attr_reader :zip_file, :temp_location

    validates :zip_file, presence: true
    validate :is_a_zip_file

    def persisted?
      false
    end

    def initialize(zip_file, root_dir = BulkUpload::ZipFile.default_root_directory)
      @zip_file = zip_file
      @root_dir = root_dir
      FileUtils.mkdir_p(@root_dir)
      store_temporarily
    end

    def temp_dir
      @temp_dir ||= Dir.mktmpdir(nil, @root_dir)
    end

    def store_temporarily
      return if @zip_file.nil?
      @temp_location = File.join(self.temp_dir, self.zip_file.original_filename)
      FileUtils.cp(self.zip_file.tempfile, @temp_location)
    end

    def extracted_files
      @extracted_files ||=
        extract_contents.
          split(/[\r\n]+/).
          map { |l| l.strip }.
          reject { |l| l =~ /\A(Archive|creating):/ }.
          map { |f| f.gsub(/\Ainflating:\s+/, '') }.
          reject { |f| f =~ /\/__MACOSX\// }.
          map { |f| File.expand_path(f) }
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
      _, _, errs = Open3.popen3("#{Whitehall.system_binaries[:zipinfo]} -1 #{self.temp_location} > /dev/null")
      errs.read.empty?
    end
  end

  class Attachments
    extend ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Conversion

    attr_reader :attachments

    def self.from_files(file_paths)
      attachment_params = file_paths.map do |file|
        { attachment_data_attributes: { file: File.open(file) } }
      end

      new(attachment_params)
    end

    def initialize(params)
      @attachments = params.map {|p| Attachment.new(p) }
    end

    def to_model
      self
    end

    def persisted?
      false
    end
  end
end
