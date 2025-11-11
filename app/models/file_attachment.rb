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

  def self.readable_type
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
      assets:,
    }
  end

  def publishing_component_params
    super.merge({
      id: filename,
      content_type:,
      filename:,
      file_size:,
      preview_url: previewable? ? preview_path : nil,
      alternative_format_contact_email: accessible? ? nil : alternative_format_contact_email,
      number_of_pages: pdf? ? number_of_pages : nil,
    }).compact
  end

  def alternative_format_contact_email
    attachable.alternative_format_contact_email
  rescue NoMethodError
    nil
  end

  def previewable?
    csv? && attachable.is_a?(Edition)
  end

  def preview_path
    if attachment_data.all_asset_variants_uploaded?
      "/csv-preview/#{attachment_data.assets.first.asset_manager_id}/#{attachment_data.assets.first.filename}"
    end
  end

private

  def assets
    return unless attachable.is_a?(Edition) && attachment_data.all_asset_variants_uploaded?

    attachment_data.assets.map do |asset|
      {
        asset_manager_id: asset.asset_manager_id,
        filename: asset.filename,
      }
    end
  end
end
