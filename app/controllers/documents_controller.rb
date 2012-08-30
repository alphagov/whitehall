class DocumentsController < PublicFacingController
  before_filter :find_document, only: [:show]

  private

  def preview?
    params[:preview] && user_signed_in?
  end

  def find_document
    unless @document = find_document_or_edition
      render text: "Not found", status: :not_found
    end
  end

  def find_document_or_edition
    if preview?
      document_class.find(params[:preview])
    else
      document_class.published_as(params[:id])
    end
  end

  def document_class
    Edition
  end
end
