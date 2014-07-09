class StatisticsController < PublicationsController
  enable_request_formats index: [:json]
  before_filter :inject_statistics_publication_filter_option_param, only: :index

  def index
    @filter = build_document_filter
    @filter.publications_search

    respond_to do |format|
      format.html do
        @filter = DocumentFilterPresenter.new(@filter, view_context, PublicationesquePresenter)
      end
      format.json do
        render json: StatisticsFilterJsonPresenter.new(@filter, view_context, PublicationesquePresenter)
      end
    end
  end

private
  def inject_statistics_publication_filter_option_param
    params[:publication_filter_option] = "statistics"
  end
end
