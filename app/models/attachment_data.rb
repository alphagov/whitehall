require "pdf-reader"
require "timeout"

class AttachmentData < ApplicationRecord
  include Replaceable
  include AssetData

  mount_uploader :file, AttachmentUploader, mount_on: :carrierwave_file, validate_integrity: true

  has_many :attachments, -> { order(:attachable_id) }, inverse_of: :attachment_data

  delegate :url, :path, to: :file, allow_nil: true

  before_save :update_file_attributes

  validate :new_filename_blank
  validate :file_is_not_blank
  validate :file_is_not_empty
  validate :filename_is_unique

  attr_accessor :attachable, :keep_or_replace, :new_filename

  OPENDOCUMENT_EXTENSIONS = %w[ODT ODP ODS].freeze

  def filename
    file&.file&.filename
  end

  def filename_without_extension
    filename && filename.sub(/.[^.]*$/, "")
  end

  def file_extension
    File.extname(filename).delete(".") if filename.present?
  end

  def pdf?
    content_type == AttachmentUploader::PDF_CONTENT_TYPE
  end

  def txt?
    file_extension == "txt"
  end

  def csv?
    return file_extension.casecmp("csv").zero? if file_extension

    false
  end

  # Is in OpenDocument format? (see https://en.wikipedia.org/wiki/OpenDocument)
  def opendocument?
    OPENDOCUMENT_EXTENSIONS.include? file_extension.upcase
  end

  def indexable?
    AttachmentUploader::INDEXABLE_TYPES.include?(file_extension)
  end

  def all_asset_variants_uploaded?
    asset_variants = assets.map(&:variant).compact.map(&:to_sym)

    (%i[original] - asset_variants).empty?
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

  def auth_bypass_ids
    attachable && attachable.respond_to?(:auth_bypass_id) ? [attachable.auth_bypass_id] : []
  end

  def keep_existing_file?
    to_replace_id.present? && keep_or_replace != "replace"
  end

private

  def calculate_number_of_pages
    Timeout.timeout(10) do
      PDF::Reader.new(path).page_count
    end
  rescue Timeout::Error, PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError, OpenSSL::Cipher::CipherError
    nil
  end

  def attachment_with_same_filename
    attachable && attachable.attachments.with_filename(filename).first
  end

  def attachment_with_same_new_filename
    attachable && attachable.attachments.with_filename(new_filename).first
  end

  def filename_is_unique
    return if keep_or_replace == "keep" && new_filename.present? && !attachment_with_same_new_filename

    if attachment_with_same_new_filename && keep_or_replace == "keep"
      errors.add(:file, "with name \"#{filename}\" already attached to document")
    end

    if !same_filename_as_replacement? && attachment_with_same_filename && attachment_with_same_filename.attachment_data != self
      errors.add(:file, "with name \"#{filename}\" already attached to document")
    end
  end

  def file_is_not_blank
    errors.add(:file, :blank) if file.blank? && errors[:file].blank?
  end

  def file_is_not_empty
    errors.add(:file, "is an empty file") if file.present? && file.file.zero_size?
  end

  def new_filename_blank
    errors.add(:new_filename, :blank) if keep_or_replace == "keep" && new_filename.blank?
  end
end
