class CsvPreviewController < BaseAttachmentsController
  def show
    respond_to do |format|
      format.html do
        if attachment_data.csv? && attachment_visible? && attachment_data.visible_edition_for(current_user)
          expires_headers
          @edition = attachment_data.visible_edition_for(current_user)
          @attachment = attachment_data.visible_attachment_for(current_user)
          begin
            @csv_preview = CsvFileFromPublicHost.csv_preview(attachment_data.file.asset_manager_path)
          rescue CsvPreview::FileEncodingError, CSV::MalformedCSVError, CsvFileFromPublicHost::ConnectionError, CsvFileFromPublicHost::FileEncodingError
          end
          render layout: 'html_attachments'
        else
          fail
        end
      end
    end
  rescue ActionController::UnknownFormat
    render status: :not_acceptable, plain: "Request format #{request.format} not handled."
  end
end
