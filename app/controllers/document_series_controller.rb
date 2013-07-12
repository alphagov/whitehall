class DocumentSeriesController < PublicFacingController
  include CacheControlHelper
  before_filter :load_organisation

  def index
    redirect_to publications_path(departments: [@organisation])
  end

  def show
    @document_series = @organisation.document_series.find(params[:id])
    @published_publications = decorate_collection(@document_series.published_publications.in_reverse_chronological_order, PublicationesquePresenter)
    @published_consultations = decorate_collection(@document_series.published_consultations.in_reverse_chronological_order, PublicationesquePresenter)
    @published_statistical_data_sets = decorate_collection(@document_series.published_statistical_data_sets.in_reverse_chronological_order, StatisticalDataSetPresenter)
    @published_speeches = decorate_collection(@document_series.published_speeches.in_reverse_chronological_order, SpeechPresenter)
    @published_detailed_guides = decorate_collection(@document_series.published_detailed_guides.in_reverse_chronological_order, DetailedGuidePresenter)
    @published_case_studies = decorate_collection(@document_series.published_case_studies.in_reverse_chronological_order, CaseStudyPresenter)
    @published_news_articles = decorate_collection(@document_series.published_news_articles.in_reverse_chronological_order, NewsArticlePresenter)

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
