class CsvPreviewController < BaseAttachmentsController
  def show
    respond_to do |format|
      format.html do
        if attachment_data.csv? && attachment_visible? && attachment_visibility.visible_edition
          expires_headers
          @edition = attachment_visibility.visible_edition
          @attachment = attachment_visibility.visible_attachment
          CsvFileFromPublicHost.new(@attachment.file.file.asset_manager_path) do |file|
            @csv_preview = CsvPreview.new(file.path)
          end
          render layout: 'html_attachments'
        else
          fail
        end
      end
    end
  rescue CsvPreview::FileEncodingError, CSV::MalformedCSVError, CsvFileFromPublicHost::ConnectionError
    render layout: 'html_attachments'
  rescue ActionController::UnknownFormat
    render status: :not_acceptable, plain: "Request format #{request.format} not handled."
  end
end
