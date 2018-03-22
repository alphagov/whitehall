class CsvPreviewController < BaseAttachmentsController
  def show
    respond_to do |format|
      format.html do
        if attachment_data.csv? && attachment_visible? && visible_edition
          expires_headers
          @edition = visible_edition
          @attachment = attachment_data.visible_attachment_for(current_user)
          csv_response = CsvFileFromPublicHost.csv_response(attachment_data.file.asset_manager_path)
          @csv_preview = CsvFileFromPublicHost.csv_preview_from(csv_response)
          render layout: 'html_attachments'
        else
          fail
        end
      end
    end
  end

private

  def fail
    if attachment_data.unpublished?
      redirect_url = attachment_data.unpublished_edition.unpublishing.document_path
      redirect_to redirect_url
    elsif attachment_data.replaced?
      expires_headers
      redirect_to attachment_data.replaced_by.url, status: 301
    elsif incoming_upload_exists? upload_path
      redirect_to_placeholder
    else
      render plain: "Not found", status: :not_found
    end
  end

  def visible_edition
    @visible_edition ||= attachment_data.visible_edition_for(current_user)
  end

  def incoming_upload_exists?(path)
    path = path.sub(Whitehall.clean_uploads_root, Whitehall.incoming_uploads_root)
    File.exist?(path)
  end

  def upload_exists?(path)
    File.exist?(path) && file_is_clean?(path)
  end
end
