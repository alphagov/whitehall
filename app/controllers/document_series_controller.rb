class DocumentSeriesController < PublicFacingController
  before_filter :load_organisation

  def index
    redirect_to publications_path(departments: [@organisation])
  end

  def show
    @document_series = @organisation.document_series.find(params[:id])
    @published_editions = PublicationesquePresenter.decorate(@document_series.published_editions)
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
