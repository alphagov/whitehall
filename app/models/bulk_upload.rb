class BulkUpload
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  validate :attachments_must_be_valid

  attr_reader :attachable, :attachments, :files

  def initialize(attachable)
    if attachable.nil?
      throw Error("No attachable specified")
    end

    @attachable = attachable
    @attachments = []
  end

  def build_attachments_from_files(files)
    @attachments = if files.present? && files.compact.present?
                     files.compact.map { |file| build_attachment_for_file(file) }
                   else
                     errors.add(:files, message: "not selected for upload")
                   end
  end

  def build_attachments_from_params(params)
    @attachments = if params.present?
                     params.values.map(&method(:create_or_update_attachment)).compact_blank
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

    unless attachment.new_record?
      attachment_data = attachment.attachment_data
      existing_attachment_filenames = @attachable.attachments.select(&:file?).map(&:filename).join(" ")
      existing_attachment_count = existing_attachment_filenames.scan(attachment_data.filename_without_extension).count

      new_filename = "#{attachment_data.filename_without_extension}_#{existing_attachment_count}.#{attachment_data.file_extension}"

      if @attachable.attachments.with_filename(new_filename).present?
        new_filename = "#{attachment_data.filename_without_extension}_#{existing_attachment_count + 1}.#{attachment_data.file_extension}"
      end

      attachment.attachment_data_attributes = { file:, to_replace_id: attachment.attachment_data.id, keep_or_replace: "keep", new_filename: }
    end

    attachment.attachment_data.valid?

    if attachment.attachment_data.errors[:file].present?
      errors.add(:files, message: "included #{filename}: #{attachment.attachment_data.errors.messages_for(:file).join(', ')}")
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
    @attachable.attachments.with_filename(filename).first
  end

  def create_or_update_attachment(attachment_params)
    attachment_attributes = attachment_params.except(:attachment_data_attributes)
    attachment_data_attributes = attachment_params.fetch(:attachment_data_attributes, {})

    attachment = case attachment_data_attributes[:keep_or_replace]
                 when "keep"
                   if attachment_data_attributes[:new_filename].present?
                     new_attachment = FileAttachment.new(**attachment_attributes.except(:id), attachment_data_attributes: attachment_data_attributes.except(:to_replace_id))
                     new_file = CarrierWave::SanitizedFile.new(new_attachment.file)
                     new_file.move_to(File.join(File.dirname(new_file.path), new_attachment.attachment_data.new_filename))
                     new_attachment.attachment_data.file = new_file
                     new_attachment
                   else
                     attachment = FileAttachment.find_by(id: attachment_attributes[:id])
                     attachment.assign_attributes(**attachment_attributes.except(:id), attachment_data_attributes:)
                     attachment
                   end
                 when "replace"
                   existing_attachment = FileAttachment.find_by(id: attachment_attributes[:id])
                   existing_attachment.assign_attributes(attachment_attributes.except(:id))
                   existing_attachment.build_attachment_data(**attachment_data_attributes, to_replace_id: existing_attachment.attachment_data.id)
                   existing_attachment
                 else
                   FileAttachment.new(**attachment_attributes.except(:id), attachment_data_attributes:)
                 end

    attachment.attachable = @attachable
    attachment.attachment_data.attachable = @attachable

    attachment
  end
end
