class Admin::EditionDocumentHistoryController < Admin::EditionsController
  layout nil

  before_action :find_history_edition
  before_action :limit_edition_access!

  def index
    @document_history = Document::PaginatedTimeline.new(document: @edition.document, page: params[:page] || 1, only: params[:only])

    render(html: Admin::Editions::DocumentHistoryTabComponent.new(edition: @edition, document_history: @document_history, editing: params[:editing]).render_in(view_context))
  end

private

  def find_history_edition
    @edition = Edition.find_by(id: params[:edition_id]) || Edition.find(params[:id])
  end
end
