class FileAttachment < Attachment
  include Rails.application.routes.url_helpers

  extend FriendlyId
  include HasContentId
  friendly_id { |config| config.routes = false }

  delegate :url,
           :content_type,
           :pdf?,
           :csv?,
           :opendocument?,
           :file_extension,
           :file_size,
           :number_of_pages,
           :file,
           :filename,
           :filename_without_extension,
           to: :attachment_data

  accepts_nested_attributes_for :attachment_data, reject_if: ->(attributes) { attributes[:file].blank? && attributes[:file_cache].blank? }

  validate :filename_is_unique

  def filename_changed?
    previous_attachment_data_id = attachment_data_id_was
    previous_attachment_data = AttachmentData.find(previous_attachment_data_id)
    current_attachment_data = attachment_data

    previous_attachment_data.filename != current_attachment_data.filename
  end

  def file?
    true
  end

  def name_for_link
    filename
  end

  def readable_type
    "file"
  end

  def should_generate_new_friendly_id?
    false
  end

  def publishing_api_details_for_format
    {
      accessible: accessible?,
      alternative_format_contact_email:,
      content_type:,
      file_size:,
      filename:,
      number_of_pages:,
      preview_url:,
    }
  end

private

  def alternative_format_contact_email
    attachable.alternative_format_contact_email
  rescue NoMethodError
    nil
  end

  def preview_url
    if csv? && attachable.is_a?(Edition)
      Plek.asset_root + "/government/uploads/system/uploads/attachment_data/file/#{attachment_data.id}/#{filename}/preview"
    end
  end

  def filename_is_unique
    if attachable && attachable.attachments.any? { |a| a.file? && a != self && a.filename.downcase == filename.try(:downcase) }
      errors.add(:base, message: "This #{attachable_model_name} already has a file called \"#{filename}\"")
    end
  end
end
