class DocumentSeriesController < PublicFacingController
  before_filter :load_organisation

  def index
    redirect_to publications_path(departments: [@organisation])
  end

  def show
    @document_series = @organisation.document_series.find(params[:id])
    @published_publications = PublicationesquePresenter.decorate(@document_series.published_publications)
    @published_statistical_data_sets = StatisticalDataSetPresenter.decorate(@document_series.published_statistical_data_sets)
    set_slimmer_organisations_header([@document_series.organisation])
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
