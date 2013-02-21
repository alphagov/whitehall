class DocumentsController < PublicFacingController
  include CacheControlHelper
  include PublicDocumentRoutesHelper

  before_filter :find_document, only: [:show]
  before_filter :redirect_to_canonical_url

  private

  def preview?
    params[:preview]
  end

  def current_user_can_preview?
    preview? && user_signed_in?
  end

  def find_document
    unless @document = find_document_or_edition
      if @document = document_class.scheduled_for_publication_as(params[:id])
        expire_on_next_scheduled_publication([@document])
        render :coming_soon
      elsif @unpublishing = document_class.unpublished_as(params[:id])
        # NOTE: We should be returning a 410 here, but because 4XX statuses get clobbered upstream,
        # we are forced to return 200 for now. There may also be the potential to automatically redirect
        # when the reason for unpublishing is UnpublishingReason::Duplicate or UnpublishingReason::Superseded.
        render :unpublished
      else
        render text: "Not found", status: :not_found
      end
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

  def redirect_to_canonical_url
    redirect_to public_document_path(@document) if request.query_parameters[:locale] == 'en'
  end
end
