class Admin::EditionAuditTrailController < Admin::EditionsController
  layout nil

  def index
    @edition = Edition.find(params[:id])
    @document_history = Document::PaginatedHistory.new(@edition.document, params[:page])
  end
end
