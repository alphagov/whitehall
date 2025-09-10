require "pdf-reader"
require "timeout"

class AttachmentData < ApplicationRecord
  mount_uploader :file, AttachmentUploader, mount_on: :carrierwave_file, validate_integrity: true

  has_many :attachments, -> { order(:attachable_id) }, inverse_of: :attachment_data
  has_many :assets,
           as: :assetable,
           inverse_of: :assetable

  delegate :url, :path, to: :file, allow_nil: true

  before_save :update_file_attributes

  validate :file_is_not_blank
  validate :file_is_not_empty
  validate :filename_is_unique

  attr_accessor :to_replace_id, :attachable

  belongs_to :replaced_by, class_name: "AttachmentData"
  validate :cant_be_replaced_by_self
  after_save :handle_to_replace_id

  OPENDOCUMENT_EXTENSIONS = %w[ODT ODP ODS].freeze

  def filename
    file.present? && file.file.filename
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

  def asset_uploaded?
    assets.any? { |asset| asset.variant.to_sym == :original }
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
    raise ActiveRecord::RecordInvalid, self if errors.any?

    update_column(:replaced_by_id, replacement.id)
  end

  def deleted?
    significant_attachment(include_deleted_attachables: true).deleted?
  end

  def draft?
    !significant_attachable.publicly_visible?
  end

  def needs_publishing?
    attachments.size == 1 && attachments.first.attachable.publicly_visible?
  end

  def needs_discarding?
    attachments.size == 1
  end

  delegate :accessible_to?, to: :significant_attachable

  delegate :access_limited?, to: :last_attachable

  delegate :access_limited_object, to: :last_attachable

  delegate :unpublished?, to: :unpublished_attachable

  def replaced?
    replaced_by.present?
  end

  def replacement_asset_for(asset)
    replaced_by.assets.where(variant: asset.variant).first || replaced_by.assets.where(variant: Asset.variants[:original]).first
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
    # below code seems wrong, policy group is not a edition but could be visible
    visible_attachable.is_a?(Edition) ? visible_attachable : nil
  end

  def draft_attachment_for(user)
    visible_to?(user) ? attachments.find { |attachment| attachment.attachable_type == "Edition" && attachment.attachable&.draft? } : nil
  end

  def draft_edition_for(user)
    draft_attachable = draft_attachment_for(user)&.attachable
    draft_attachable.is_a?(Edition) ? draft_attachable : nil
  end

  def draft_attachment
    attachments.find { |attachment| attachment.attachable_type == "Edition" && Edition::PRE_PUBLICATION_STATES.include?(attachment.attachable&.state) }
  end

  def draft_edition
    draft_attachable = draft_attachment&.attachable
    draft_attachable.is_a?(Edition) ? draft_attachable : nil
  end

  def significant_attachable
    significant_attachment.attachable || Attachable::Null.new
  end

  def last_attachable
    last_attachment.attachable || Attachable::Null.new
  end

  def unpublished_attachable
    unpublished_attachment&.attachable || Attachable::Null.new
  end

  def significant_attachment(**args)
    last_publicly_visible_attachment || last_attachment(**args)
  end

  def last_attachment(**args)
    filtered_attachments(**args).last || Attachment::Null.new
  end

  def unpublished_attachment
    attachments.reverse.detect { |a| a.attachable&.unpublished? }
  end

  def last_publicly_visible_attachment
    attachments.reverse.detect { |a| (a.attachable || Attachable::Null.new).publicly_visible? }
  end

  def auth_bypass_ids
    attachable && attachable.respond_to?(:auth_bypass_id) ? [attachable.auth_bypass_id] : []
  end

  def redirect_url
    return nil unless unpublished?

    unpublished_attachable.unpublishing.document_url
  end

  def attachable_url(user = nil)
    visible_edition = visible_edition_for(user)
    if visible_edition.blank? && draft_edition
      draft_edition.public_url(draft: true)
    elsif visible_edition.present?
      visible_edition.public_url
    end
  end

  def access_limitation
    return [] unless access_limited?

    AssetManagerAccessLimitation.for(access_limited_object)
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
    Timeout.timeout(10) do
      PDF::Reader.new(path).page_count
    end
  rescue Timeout::Error, PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError, OpenSSL::Cipher::CipherError
    nil
  end

  def attachment_with_same_filename
    attachable && attachable.attachments.with_filename(filename).first
  end

  def same_filename_as_replacement?
    return if to_replace_id.blank?

    to_replace = AttachmentData.find(to_replace_id)

    to_replace && to_replace.filename == filename
  end

  def filename_is_unique
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
end
