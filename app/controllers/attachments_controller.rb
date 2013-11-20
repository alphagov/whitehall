class AttachmentsController < PublicUploadsController
  include PublicDocumentRoutesHelper

  before_filter :reject_non_previewable_attachments, only: :preview

  def preview
    if attachment_visible? && attachment_visibility.visible_edition
      expires_headers
      @edition = attachment_visibility.visible_edition
      @attachment = attachment_visibility.visible_attachment
      @csv_preview = CsvPreview.new(upload_path)
      render layout: 'html_attachments'
    else
      fail
    end
  end

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

  def analytics_format
    @edition.type.underscore.to_sym
  end

  def set_slimmer_template
    slimmer_template('chromeless')
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

  def reject_non_previewable_attachments
    render(text: "Not found", status: :not_found) unless attachment_data.csv?
  end
end
