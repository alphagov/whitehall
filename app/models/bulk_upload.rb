require "tmpdir"
require "open3"

class BulkUpload
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  validate :attachments_must_be_valid

  attr_reader :edition, :attachments, :files, :invalid_file_types

  def initialize(edition, files: nil, attachments_params: [])
    if edition.nil?
      throw Error("No edition specified")
    end

    @invalid_file_types = []

    @edition = edition
    @attachments = if files
                     errors.add(:files, message: "not selected for upload") if files.compact.blank?
                     files.compact.map { |file| build_attachment_for_file(file) }
                   elsif attachments_params.present?
                     attachments_params.values.map(&method(:find_and_update_existing_attachment))
                   else
                     []
                   end
  end

  def build_attachment_for_file(uploaded_file)
    if uploaded_file.blank?
      errors.add(:files, message: "not selected for upload")
      return
    end

    filename = uploaded_file.original_filename.gsub(" ", "_")

    temp_dir = Dir.mktmpdir(nil, Whitehall.bulk_upload_tmp_dir)

    temp_location = File.join(temp_dir, filename)

    FileUtils.cp(uploaded_file, temp_location)

    file = File.open(temp_location)

    attachment = find_attachment_with_file(filename) || FileAttachment.new(attachment_data_attributes: { file: })

    unless AttachmentUploader::MIME_ALLOW_LIST.include?(Marcel::MimeType.for(uploaded_file))
      @invalid_file_types << File.extname(filename)
      errors.clear
      errors.add(:files, message: "included not allowed types #{invalid_file_types.uniq.join(', ')}")
    end

    unless attachment.new_record?
      attachment.attachment_data_attributes = { file:, to_replace_id: attachment.attachment_data.id }
    end

    attachment
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
      attachments.all? { |a| a.save(context: :user_input) }
    else
      false
    end
  end

  def attachments_must_be_valid
    invalid_attachments = attachments.reject { |a| a.valid?(context: :user_input) }

    errors.add(:base, message: "Please enter missing fields for each attachment") if invalid_attachments.present?
  end

private

  def find_attachment_with_file(filename)
    @edition.attachments.with_filename(filename).first
  end

  def find_and_update_existing_attachment(attachment_params)
    attachment_attributes = attachment_params.except(:attachment_data_attributes)
    attachment_data_attributes = attachment_params.fetch(:attachment_data_attributes, {})
    attachment_data_attributes[:attachable] = @edition

    if (attachment = FileAttachment.find_by(id: attachment_attributes[:id]))
      replaced_data_id = attachment.attachment_data.id
      attachment.attributes = attachment_attributes
      attachment.attachment_data = AttachmentData.new(attachment_data_attributes)
      attachment.attachment_data.to_replace_id = replaced_data_id
    end

    attachment || FileAttachment.new(attachment_params)
  end
end
