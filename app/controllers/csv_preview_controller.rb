class CsvPreviewController < BaseAttachmentsController
  def show
    respond_to do |format|
      format.html do
        unless attachment_data.csv?
          render_not_found
          return
        end

        if infected? || !exists?
          render_not_found
          return
        end

        if unscanned?
          redirect_to_placeholder
          return
        end

        unless !attachment_data.deleted? && !attachment_data.unpublished? && !attachment_data.replaced? && (!attachment_data.draft? || (attachment_data.draft? && attachment_data.accessible_to?(current_user))) && attachment_data.visible_edition_for(current_user)
          if attachment_data.unpublished?
            redirect_url = attachment_data.unpublished_edition.unpublishing.document_path
            redirect_to redirect_url
          elsif attachment_data.replaced?
            expires_headers
            redirect_to attachment_data.replaced_by.url, status: 301
          else
            render_not_found
          end
          return
        end

        expires_headers
        @edition = attachment_data.visible_edition_for(current_user)
        @attachment = attachment_data.visible_attachment_for(current_user)
        CsvFileFromPublicHost.new(attachment_data.file.asset_manager_path) do |file|
          @csv_preview = CsvPreview.new(file.path)
        end
        render layout: 'html_attachments'
      end
    end
  rescue CsvPreview::FileEncodingError, CSV::MalformedCSVError, CsvFileFromPublicHost::ConnectionError
    render layout: 'html_attachments'
  rescue ActionController::UnknownFormat
    render status: :not_acceptable, plain: "Request format #{request.format} not handled."
  end
end
