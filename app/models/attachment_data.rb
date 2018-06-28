require 'pdf-reader'

class AttachmentData < ApplicationRecord
  mount_uploader :file, AttachmentUploader, mount_on: :carrierwave_file

  has_many :attachments, -> { order(:attachable_id) }, inverse_of: :attachment_data

  delegate :url, :path, to: :file, allow_nil: true

  before_save :update_file_attributes

  validates :file, presence: true, unless: :virus_scan_pending?
  validate :file_is_not_empty

  attr_accessor :to_replace_id
  belongs_to :replaced_by, class_name: 'AttachmentData'
  validate :cant_be_replaced_by_self
  after_save :handle_to_replace_id

  OPENDOCUMENT_EXTENSIONS = %w(ODT ODP ODS).freeze

  attr_accessor :attachable

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

  def uploaded_to_asset_manager!
    update!(uploaded_to_asset_manager_at: Time.zone.now)
    ServiceListeners::AttachmentUpdater.update_attachment_data! self
  end

  def uploaded_to_asset_manager?
    uploaded_to_asset_manager_at.present?
  end

  def deleted?
    significant_attachment(include_deleted_attachables: true).deleted?
  end

  def draft?
    !significant_attachable.publicly_visible?
  end

  def accessible_to?(user)
    significant_attachable.accessible_to?(user)
  end

  def access_limited?
    last_attachable.access_limited?
  end

  def access_limited_object
    last_attachable.access_limited_object
  end

  def unpublished?
    last_attachable.unpublished?
  end

  def unpublished_edition
    last_attachable.unpublished_edition
  end

  def replaced?
    replaced_by.present?
  end

  def visible_to?(user)
    !deleted? && (!draft? || (draft? && accessible_to?(user)))
  end

  def visible_attachment_for(user)
    visible_to?(user) ? significant_attachment : nil
  end

  def visible_attachable_for(user)
    visible_to?(user) ? significant_attachable : nil
  end

  def visible_edition_for(user)
    visible_attachable = visible_attachable_for(user)
    visible_attachable.is_a?(Edition) ? visible_attachable : nil
  end

  def significant_attachable
    significant_attachment.attachable || Attachable::Null.new
  end

  def last_attachable
    last_attachment.attachable || Attachable::Null.new
  end

  def significant_attachment(**args)
    last_publicly_visible_attachment || last_attachment(**args)
  end

  def last_attachment(**args)
    filtered_attachments(**args).last || Attachment::Null.new
  end

  def last_publicly_visible_attachment
    attachments.reverse.detect { |a| (a.attachable || Attachable::Null.new).publicly_visible? }
  end

private

  def filtered_attachments(include_deleted_attachables: false)
    if include_deleted_attachables
      attachments
    else
      attachments.select { |attachment| attachment.attachable.present? }
    end
  end

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
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError, OpenSSL::Cipher::CipherError
    return nil
  end

  def file_is_not_empty
    errors.add(:file, "is an empty file") if file.present? && file.file.zero_size?
  end

  def virus_scan_pending?
    path.present? && virus_status == :pending
  end
end
