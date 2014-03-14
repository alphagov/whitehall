class StatisticalReleaseAnnouncementsController < PublicFacingController
  def index
    @filter = Frontend::StatisticalReleaseAnnouncementsFilter.new(filter_params)
  end

private
  def filter_params
    Hash(params[:statistical_release_announcements_filter]).merge({ page: params[:page] })
  end
end
