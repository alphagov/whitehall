class Admin::EditionAuditTrailController < Admin::EditionsController
  layout nil

  def index
    @edition = Edition.find(params[:id])
    @edition_history = Kaminari.paginate_array(@edition.document_version_trail.reverse).page(params[:page]).per(30)
  end
end