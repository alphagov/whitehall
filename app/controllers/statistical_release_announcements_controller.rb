class StatisticalReleaseAnnouncementsController < PublicFacingController
  def index
    @filter = Frontend::StatisticalReleaseAnnouncementsFilter.new(filter_params)
  end

private
  def filter_params
    params.slice(:page, :keywords, :from_date, :to_date)
  end
end
