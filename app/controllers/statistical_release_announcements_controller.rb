class StatisticalReleaseAnnouncementsController < PublicFacingController
  def index
    @filter = Frontend::StatisticalReleaseAnnouncementsFilter.new(params[:statistical_release_announcements_filter])
    @release_announcements = Frontend::StatisticalReleaseAnnouncementProvider.find_by(@filter.valid_filter_params)
  end
end
