class BulkUpload
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  validate :attachments_must_be_valid

  attr_reader :edition, :attachments, :files

  def initialize(edition)
    if edition.nil?
      throw Error("No edition specified")
    end

    @edition = edition
    @attachments = []
  end

  def build_attachments_from_files(files)
    @attachments = if files.compact.present?
                     files.compact.map { |file| build_attachment_for_file(file) }
                   else
                     errors.add(:files, message: "not selected for upload")
                   end
  end

  def build_attachments_from_params(params)
    @attachments = if params.present?
                     params.values.map(&method(:find_and_update_existing_attachment))
                   else
                     errors.add(:base, message: "No attachments specified")
                   end
  end

  def to_model
    self
  end

  def persisted?
    false
  end

  def save_attachments
    valid? && attachments.all? { |a| a.save(context: :user_input) }
  end

  def attachments_must_be_valid
    invalid_attachments = attachments.reject { |a| a.valid?(context: :user_input) }

    errors.add(:base, message: "Please enter missing fields for each attachment") if invalid_attachments.present?
  end

private

  def build_attachment_for_file(uploaded_file)
    if uploaded_file.blank?
      errors.add(:files, message: "not selected for upload")
      return
    end

    sanitized_file = convert_to_sanitized_file(uploaded_file)

    filename = sanitized_file.filename
    file = File.open(sanitized_file.path)

    attachment = find_attachment_with_file(filename) || FileAttachment.new(attachment_data_attributes: { file: })

    unless AttachmentUploader::MIME_ALLOW_LIST.include?(sanitized_file.content_type)
      errors.add(:files, message: "included not allowed type #{File.extname(filename)}")
    end

    unless attachment.new_record?
      attachment.attachment_data_attributes = { file:, to_replace_id: attachment.attachment_data.id }
    end

    attachment
  end

  def convert_to_sanitized_file(uploaded_file)
    # Using CarrierWave::SanitizedFile means that the filename is
    # sanitized in the same way as other uploaded files.
    sanitized_file = CarrierWave::SanitizedFile.new(uploaded_file)

    # Uploaded files are renamed by Rails but we want to retain
    # `original_filename` so a file can be reuploaded and keep it's
    # associated `FileAttachment`. In this step we run `move_to` i.e.
    # `mv TEMP_DIR/TEMP_FILENAME TEMP_DIR/ORIGINAL_FILENAME`
    # which renames the uploaded file to `original_filename`.
    sanitized_file.move_to(File.join(File.dirname(sanitized_file.path), sanitized_file.filename))

    sanitized_file
  end

  def find_attachment_with_file(filename)
    @edition.attachments.with_filename(filename).first
  end

  def find_and_update_existing_attachment(attachment_params)
    attachment_attributes = attachment_params.except(:attachment_data_attributes)
    attachment_data_attributes = attachment_params.fetch(:attachment_data_attributes, {})
    attachment_data_attributes[:attachable] = @edition

    attachment = FileAttachment.find_by(id: attachment_attributes[:id]) || FileAttachment.new(attachment_params)
    attachment.attributes = attachment_attributes.except(:id)

    unless attachment.new_record?
      attachment_data_attributes[:to_replace_id] = attachment.attachment_data.id
    end

    attachment.attachment_data = AttachmentData.new(attachment_data_attributes)

    attachment.attachable = @edition

    attachment
  end
end
