class Admin::EditionAuditTrailController < Admin::EditionsController
  layout nil

  def index
    @edition = Edition.find_by(id: params[:edition_id]) || Edition.find(params[:id])

    if preview_design_system?(next_release: false)
      @document_history = Document::PaginatedTimeline.new(document: @edition.document, page: params[:page] || 1)

      render(html: Admin::Editions::DocumentHistoryTabComponent.new(edition: @edition, document_history: @document_history, editing: params[:editing]).render_in(view_context))
    else
      @document_history = Document::PaginatedHistory.new(@edition.document, params[:page])
    end
  end
end
