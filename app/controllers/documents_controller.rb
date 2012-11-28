class DocumentsController < PublicFacingController
  include CacheControlHelper

  before_filter :find_document, only: [:show]

  private

  def preview?
    params[:preview]
  end

  def current_user_can_preview?
    preview? && user_signed_in?
  end

  def find_document
    unless @document = find_document_or_edition
      if document = document_class.scheduled_for_publication_as(params[:id])
        expire_on_next_scheduled_publication([document])
      end
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
