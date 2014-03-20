class StatisticsAnnouncementsController < PublicFacingController
  def index
    @filter = Frontend::StatisticsAnnouncementsFilter.new(filter_params)
  end

  def show
    @announcement = Frontend::StatisticsAnnouncementProvider.find_by_slug(params[:id])
    render text: "Not found", status: :not_found if @announcement.nil?
  end

private
  def filter_params
    params.slice(:page, :keywords, :from_date, :to_date, :organisations, :topics)
  end
end
