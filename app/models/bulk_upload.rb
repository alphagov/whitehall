require 'tmpdir'
require 'open3'

# There are two ways to create and use a BulkUpload instance. You can
# either a) call BulkUpload.from_files, which will build new FileAttachment
# instances for you, or b) call BulkUpload.new and then assign a hash
# (in a accepts_nested_attributes_for compliant format) via the
# attachments_attributes= method.
#
# Use a) when rendering a form prompting for user input, and b) when
# somebody has filled the form in, and is trying to save their changes.

class BulkUpload
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  validate :attachments_must_be_valid

  attr_reader :edition, :attachments

  def self.from_files(edition, file_paths)
    new(edition).tap do |bulk_upload|
      file_paths.each { |path| bulk_upload.build_attachment_for_file(path) }
    end
  end

  def initialize(edition)
    @edition = edition
    @attachments = []
  end

  def build_attachment_for_file(path)
    attachment = find_attachment_with_file(path) || FileAttachment.new
    replaced_data_id = attachment.attachment_data.try(:id)
    attachment.attachment_data_attributes = { file: File.open(path) }
    attachment.attachment_data.to_replace_id = replaced_data_id
    @attachments << attachment
  end

  def attachments_attributes=(attributes)
    @attachments = attributes.map do |index, params|
      attachment_attrs = params.except(:attachment_data_attrs)
      data_attrs = params.fetch(:attachment_data_attributes, {})
      find_and_update_existing_attachment(attachment_attrs, data_attrs) || FileAttachment.new(params)
    end
  end

  def to_model
    self
  end

  def persisted?
    false
  end

  def save_attachments
    attachments.each { |attachment| attachment.attachable = edition }

    if valid?
      attachments.each do |attachment|
        if attachment.new_record?
          @edition.attachments << attachment
        else
          attachment.save!
        end
      end
    else
      false
    end
  end

  def attachments_must_be_valid
    attachments.each { |attachment| attachment.valid? }
    unless attachments.all? { |attachment| attachment.valid? }
      errors[:base] << 'Please enter missing fields for each attachment'
    end
  end

  private

  def find_attachment_with_file(path)
    @edition.attachments.with_filename(File.basename(path)).first
  end

  def find_and_update_existing_attachment(attachment_attrs, data_attrs)
    if attachment = FileAttachment.find_by_id(attachment_attrs[:id])
      replaced_data_id = attachment.attachment_data.id
      attachment.attributes = attachment_attrs
      attachment.attachment_data = AttachmentData.new(data_attrs)
      attachment.attachment_data.to_replace_id = replaced_data_id
      attachment
    end
  end

  class ZipFile
    extend  ActiveModel::Naming
    include ActiveModel::Validations
    include ActiveModel::Conversion

    attr_reader :zip_file, :temp_location

    validates :zip_file, presence: true
    validate :must_be_a_zip_file
    validate :contains_only_whitelisted_file_types

    def persisted?
      false
    end

    def initialize(zip_file=nil)
      @zip_file = zip_file
      store_temporarily
    end

    def temp_dir
      @temp_dir ||= Dir.mktmpdir(nil, BULK_UPLOAD_ZIPFILE_DEFAULT_ROOT_DIRECTORY)
    end

    def store_temporarily
      return if @zip_file.nil?
      @temp_location = File.join(self.temp_dir, self.zip_file.original_filename)
      FileUtils.cp(self.zip_file.tempfile, @temp_location)
    end

    def extracted_file_paths
      if @extracted_files_paths.nil?
        lines = extract_contents.split(/[\r\n]+/).map { |line| line.strip }
        lines = lines
          .reject { |line| line =~ /\A(Archive|creating):/ }
          .reject { |line| line =~ /\/__MACOSX\// }
        files = lines.map { |f| f.gsub(/\A(inflating|extracting):\s+/, '') }
        @extracted_files_paths = files.map { |file| File.expand_path(file) }
      end
      @extracted_files_paths
    end

    def cleanup_extracted_files
      FileUtils.rmtree(temp_dir, secure: true)
    end

    def extract_contents
      unzip = Whitehall.system_binaries[:unzip]
      destination = File.join(self.temp_dir, 'extracted')
      @unzip_output ||= `#{unzip} -o -d #{destination} #{self.temp_location.shellescape}`
    end

    def must_be_a_zip_file
      if @zip_file.present? && (! is_a_zip?)
        errors.add(:zip_file, 'not a zip file')
      end
    end

    def is_a_zip?
      zipinfo = Whitehall.system_binaries[:zipinfo]
      _, _, errs = Open3.popen3("#{zipinfo} -1 #{self.temp_location.shellescape} > /dev/null")
      errs.read.empty?
    end

    private

    def contains_only_whitelisted_file_types
      if @zip_file.present? && is_a_zip? && contains_disallowed_file_types?
        errors.add(:zip_file, 'contains invalid files')
      end
    end

    def contains_disallowed_file_types?
      extracted_file_paths.any? do |path|
        extension = File.extname(path).sub(/^\./, '')
        ! AttachmentUploader::EXTENSION_WHITE_LIST.include?(extension)
      end
    end
  end
end
