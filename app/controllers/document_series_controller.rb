class DocumentSeriesController < PublicFacingController
  include CacheControlHelper
  before_filter :load_organisation

  def index
    redirect_to publications_path(departments: [@organisation])
  end

  def show
    @document_series = @organisation.document_series.find(params[:id])
    @published_publications = PublicationesquePresenter.decorate(@document_series.published_publications.in_reverse_chronological_order)
    @published_statistical_data_sets = StatisticalDataSetPresenter.decorate(@document_series.published_statistical_data_sets.in_reverse_chronological_order)
    set_slimmer_organisations_header([@document_series.organisation])
    expire_on_next_scheduled_publication(@document_series.scheduled_publications + @document_series.scheduled_statistical_data_sets)
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
