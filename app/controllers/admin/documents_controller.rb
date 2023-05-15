class Admin::DocumentsController < Admin::BaseController
  def by_content_id
    document = (
      Document.find_by(content_id: params[:content_id]) ||
      # If the content_id doesn't match a document, it could be a HTML
      # attachment
      HtmlAttachment.find_by(content_id: params[:content_id])&.attachable&.document
    )

    if document
      redirect_to admin_edition_path(document.latest_edition)
    else
      flash[:error] = "The requested content was not found"
      redirect_to admin_editions_path
    end
  end
end
