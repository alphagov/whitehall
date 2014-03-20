class StatisticsAnnouncementsController < PublicFacingController
  def index
    @filter = Frontend::StatisticsAnnouncementsFilter.new(filter_params)
  end

private
  def filter_params
    params.slice(:page, :keywords, :from_date, :to_date, :organisations, :topics)
  end
end
