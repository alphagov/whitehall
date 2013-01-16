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
end
