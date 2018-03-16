class CsvPreviewController < BaseAttachmentsController
  def show
    respond_to do |format|
      format.html do
        if attachment_data.csv? && attachment_visible? && attachment_data.visible_edition_for(current_user)
          expires_headers
          @edition = attachment_data.visible_edition_for(current_user)
          @attachment = attachment_data.visible_attachment_for(current_user)
          CsvFileFromPublicHost.new(attachment_data.file.asset_manager_path) do |file|
            @csv_preview = CsvPreview.new(file.path)
          end
          render layout: 'html_attachments'
        else
          if attachment_data.unpublished?
            redirect_url = attachment_data.unpublished_edition.unpublishing.document_path
            redirect_to redirect_url
          elsif attachment_data.replaced?
            expires_headers
            redirect_to attachment_data.replaced_by.url, status: 301
          elsif image?
            redirect_to view_context.path_to_image('thumbnail-placeholder.png')
          elsif unscanned?
            redirect_to_placeholder
          else
            render plain: "Not found", status: :not_found
          end
        end
      end
    end
  rescue CsvPreview::FileEncodingError, CSV::MalformedCSVError, CsvFileFromPublicHost::ConnectionError
    render layout: 'html_attachments'
  rescue ActionController::UnknownFormat
    render status: :not_acceptable, plain: "Request format #{request.format} not handled."
  end
end
