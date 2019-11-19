class Admin::Export::DocumentController < Admin::Export::BaseController
  skip_before_action :verify_authenticity_token
  self.responder = Api::Responder

  def show
    @document = Document.find(params[:id])
    respond_with DocumentExportPresenter.new(@document)
  end

  def index
    result_set = Whitehall::Exporters::DocumentsInfoExporter.new(paginated_document_ids).call

    respond_with(
      documents: result_set,
      page_number: page_number,
      page_count: result_set.count,
    )
  end

  def lock
    document = Document.find(params[:id])
    document.update!(locked: true)
  end

  def unlock
    document = Document.find(params[:id])
    document.update!(locked: false)
  end

  def migrated
    document = Document.find(params[:id])
    return head :bad_request unless document.locked?

    document.editions.each do |edition|
      Whitehall::InternalLinkUpdater.new(edition).call
    end
  end

  private

  def paginated_document_ids
    Edition
      .joins("INNER JOIN edition_organisations eo ON eo.edition_id = editions.id")
      .joins("INNER JOIN organisations o ON o.id = eo.organisation_id")
      .where(o: { content_id: params.require(:lead_organisation) })
      .where(eo: { lead: true })
      .where(type: params.require(:type))
      .latest_edition
      .order(:document_id)
      .page(page_number)
      .per(items_per_page)
      .pluck(:document_id)
  end

  def page_number
    params.fetch(:page_number, 1)
  end

  def items_per_page
    params.fetch(:page_count, 100)
  end
end
