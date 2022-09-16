class Admin::Export::DocumentController < Admin::Export::BaseController
  skip_before_action :verify_authenticity_token
  self.responder = Api::Responder

  def show
    @document = Document.find(params[:id])
    respond_with DocumentExportPresenter.new(@document)
  end

  def index
    respond_with(
      documents: result_set,
      page_number:,
      page_count: result_set.count,
    )
  end

  def lock
    document = Document.find(params[:id])
    document.update!(locked: true) unless document.locked?
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
      Whitehall::SearchIndex.delete(edition)
    end

    ContentPublisher::FeaturedDocumentMigrator.new(document).call
    ContentPublisher::DocumentCollectionGroupMembershipMigrator.new(document).call
  end

private

  def paginated_documents
    Edition
      .joins("INNER JOIN edition_organisations eo ON eo.edition_id = editions.id
        AND eo.organisation_id = (
          SELECT organisation_id FROM edition_organisations
          WHERE `lead` IS true AND
                edition_organisations.edition_id = editions.id
          ORDER BY lead_ordering ASC
          LIMIT 1
          )")
      .joins("INNER JOIN organisations o ON o.id = eo.organisation_id")
      .joins(:document)
      .where(o: { content_id: params.require(:lead_organisation) })
      .where(eo: { lead: true })
      .by_type_or_subtypes(document_type, document_subtypes)
      .latest_edition
      .order(:document_id)
      .page(page_number)
      .per(items_per_page)
      .pluck(:document_id, "documents.content_id")
  end

  def result_set
    paginated_documents.map do |ids|
      {
        document_id: ids[0],
        content_id: ids[1],
      }
    end
  end

  def page_number
    params.fetch(:page_number, 1)
  end

  def items_per_page
    params.fetch(:page_count, 100)
  end

  def document_type
    @document_type ||= Whitehall.edition_classes.find do |type|
      type.name.underscore == params.require(:type)
    end
  end

  def document_subtypes
    return unless document_type.respond_to?(:subtypes) && params[:subtypes]

    document_type.subtypes.select do |subtype|
      Array(params[:subtypes]).include?(subtype.key)
    end
  end
end
