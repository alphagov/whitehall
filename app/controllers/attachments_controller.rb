class AttachmentsController < ApplicationController
  include UploadsControllerHelper

  def show
    if attachment_visible?
      send_upload file_path, public: current_user.nil?
    else
      replacement = attachment_data.replaced_by
      if replacement
        redirect_to replacement.url, status: 301
      else
        redirect_to_placeholder file_path
      end
    end
  end

  private

  def attachment_data
    @attachment_data ||= AttachmentData.find(params[:id])
  end

  def file_path
    File.join(Whitehall.clean_uploads_root, path_to_attachment_or_thumbnail)
  end

  def file_with_extensions
    [params[:file], params[:extension]].join('.')
  end

  def path_to_attachment_or_thumbnail
    attachment_data.file.store_path(file_with_extensions)
  end

  def attachment_visible?
    AttachmentVisibility.new(attachment_data, current_user).visible?
  end
end
