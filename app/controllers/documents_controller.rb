class DocumentsController < PublicFacingController
  before_filter :find_document, only: [:show]

  private

  def preview?
    params[:preview]
  end

  def current_user_can_preview?
    preview? && current_user
  end

  def find_document
    unless @document = find_document_or_edition
      render text: "Not found", status: :not_found
    end
  end

  def find_document_or_edition
    if current_user_can_preview?
      document_class.find(params[:preview])
    else
      document_class.published_as(params[:id])
    end
  end

  def document_class
    Edition
  end
end
