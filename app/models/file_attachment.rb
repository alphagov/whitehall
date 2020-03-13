class FileAttachment < Attachment
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
      alternative_format_contact_email: alternative_format_contact_email,
      content_type: content_type,
      file_size: file_size,
      filename: filename,
      number_of_pages: number_of_pages,
      preview_url: preview_url,
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
      Whitehall.url_maker.csv_preview_url(
        id: attachment_data.id,
        file: filename_without_extension,
        extension: file_extension,
      )
    end
  end

  def filename_is_unique
    if attachable && attachable.attachments.any? { |a| a.file? && a != self && a.filename.downcase == filename.try(:downcase) }
      self.errors[:base] << "This #{attachable_model_name} already has a file called \"#{filename}\""
    end
  end
end
