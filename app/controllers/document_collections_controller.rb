class DocumentCollectionsController < PublicFacingController
  before_filter :load_organisation

  def index
    @document_collections = @organisation.document_collections
  end

  def show
    @document_collection = @organisation.document_collections.find(params[:id])
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
