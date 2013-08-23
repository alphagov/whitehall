class DocumentSeriesController < PublicFacingController
  include CacheControlHelper
  before_filter :load_organisation

  def index
    redirect_to publications_path(departments: [@organisation])
  end

  def show
    @document_series = @organisation.document_series.find(params[:id])
    published_editions = @document_series.published_editions
    @editions = decorate_collection(published_editions, PublicationesquePresenter)
    set_slimmer_organisations_header([@document_series.organisation])
    set_slimmer_page_owner_header(@document_series.organisation)
    expire_on_next_scheduled_publication(@document_series.scheduled_editions)
    set_meta_description(@document_series.summary)
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end
