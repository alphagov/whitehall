require 'pdf-reader'

class AttachmentData < ApplicationRecord
  mount_uploader :file, AttachmentUploader, mount_on: :carrierwave_file

  has_many :attachments, inverse_of: :attachment_data

  delegate :url, :path, to: :file, allow_nil: true

  before_save :update_file_attributes

  validates :file, presence: true, unless: :virus_scan_pending?
  validate :file_is_not_empty

  attr_accessor :to_replace_id
  belongs_to :replaced_by, class_name: 'AttachmentData'
  validate :cant_be_replaced_by_self
  after_save :handle_to_replace_id

  OPENDOCUMENT_EXTENSIONS = %w(ODT ODP ODS).freeze

  def filename
    url && File.basename(url)
  end

  def filename_without_extension
    url && filename.sub(/.[^\.]*$/, '')
  end

  def file_extension
    File.extname(url).delete('.') if url.present?
  end

  def pdf?
    content_type == AttachmentUploader::PDF_CONTENT_TYPE
  end

  def txt?
    file_extension == "txt"
  end

  def csv?
    file_extension.casecmp("csv").zero?
  end

  # Is in OpenDocument format? (see https://en.wikipedia.org/wiki/OpenDocument)
  def opendocument?
    OPENDOCUMENT_EXTENSIONS.include? file_extension.upcase
  end

  def indexable?
    AttachmentUploader::INDEXABLE_TYPES.include?(file_extension)
  end

  def virus_status
    if File.exist?(infected_path)
      :infected
    elsif File.exist?(clean_path) || skip_virus_check?
      :clean
    else
      :pending
    end
  end

  def skip_virus_check?
    Rails.env.development? && !File.exist?(path)
  end

  # Newly instantiated AttachmentData will report the file path as in the incoming
  # directory because of the way Whitehall::QuarantinedFileStorage works. This method
  # will return the expected clean path, regardless of what path reports.
  def clean_path
    path.gsub(Whitehall.incoming_uploads_root, Whitehall.clean_uploads_root)
  end

  def infected_path
    clean_path.gsub(Whitehall.clean_uploads_root, Whitehall.infected_uploads_root)
  end

  def update_file_attributes
    if carrierwave_file.present? && carrierwave_file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
      if pdf?
        self.number_of_pages = calculate_number_of_pages
      end
    end
  end

  def replace_with!(replacement)
    # NOTE: we're doing this manually because carrierwave is setup such
    # that production instances aren't valid because the storage location
    # for files is not where carrierwave thinks they are (because of
    # virus-checking).
    self.replaced_by = replacement
    cant_be_replaced_by_self
    raise ActiveRecord::RecordInvalid, self if self.errors.any?
    self.update_column(:replaced_by_id, replacement.id)
    AttachmentData.where(replaced_by_id: self.id).each do |ad|
      ad.replace_with!(replacement)
    end
  end

private

  def cant_be_replaced_by_self
    return if replaced_by.nil?
    errors.add(:base, "can't be replaced by itself") if replaced_by == self
  end

  def handle_to_replace_id
    return if to_replace_id.blank?
    AttachmentData.find(to_replace_id).replace_with!(self)
  end

  def calculate_number_of_pages
    PDF::Reader.new(path).page_count
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError
    return nil
  end

  def file_is_not_empty
    errors.add(:file, "is an empty file") if file.present? && file.file.size.to_i.zero?
  end

  def virus_scan_pending?
    path.present? && virus_status == :pending
  end
end
