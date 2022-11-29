class Admin::EditionAuditTrailController < Admin::EditionsController
  layout nil

  def index
    @edition = Edition.find(params[:id])
    if preview_design_system?(next_release: true)
      @document_history = Document::PaginatedTimeline.new(document: @edition.document, page: params[:page] || 1)

      render(Admin::Editions::DocumentHistoryTabComponent.new(edition: @edition, document_history: @document_history, editing: params[:editing]))
    else
      @document_history = Document::PaginatedHistory.new(@edition.document, params[:page])
    end
  end
end
