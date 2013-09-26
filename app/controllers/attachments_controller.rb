class AttachmentsController < PublicUploadsController
  include PublicDocumentRoutesHelper

  private

  def attachment_visible?
    super && attachment_visibility.visible?
  end

  def fail
    if edition = attachment_visibility.unpublished_edition
      redirect_to public_document_path(edition, id: edition.unpublishing.slug)
    elsif replacement = attachment_data.replaced_by
      redirect_to replacement.url, status: 301
    else
      super
    end
  end

  def attachment_data
    @attachment_data ||= AttachmentData.find(params[:id])
  end

  def expires_headers
    if current_user.nil?
      super
    else
      response.headers['Cache-Control'] = 'no-cache, max-age=0, private'
    end
  end

  def upload_path
    File.join(Whitehall.clean_uploads_root, path_to_attachment_or_thumbnail)
  end

  def file_with_extensions
    [params[:file], params[:extension]].join('.')
  end

  def path_to_attachment_or_thumbnail
    attachment_data.file.store_path(file_with_extensions)
  end

  def attachment_visibility
    @attachment_visibility ||= AttachmentVisibility.new(attachment_data, current_user)
  end
end
