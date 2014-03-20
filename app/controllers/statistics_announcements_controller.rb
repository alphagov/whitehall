class StatisticsAnnouncementsController < PublicFacingController
  def index
    @filter = Frontend::StatisticsAnnouncementsFilter.new(filter_params)
  end

  def show
    @announcement = Frontend::StatisticsAnnouncementProvider.find_by_slug(params[:id])
    render text: "Not found", status: :not_found and return if @announcement.nil?
    redirect_to_published_publication(@announcement.publication)
  end

private
  def filter_params
    params.slice(:page, :keywords, :from_date, :to_date, :organisations, :topics)
  end

  def redirect_to_published_publication(publication)
    if publication.try :published?
      redirect_to(publication_path(publication))
    end
  end
end
