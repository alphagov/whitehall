class Admin::DocumentCollectionsController < Admin::BaseController
  def new
    @organisation = Organisation.find(params[:organisation_id])
    @document_collection = @organisation.document_collections.build
  end

  def create
    render nothing: true
  end
end
