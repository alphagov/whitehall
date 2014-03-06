class ReleaseAnnouncementsController < PublicFacingController
  def index
    @filter = Frontend::ReleaseAnnouncementsFilter.new(params[:release_announcements_filter])
    @release_announcements = Frontend::ReleaseAnnouncementProvider.find_by(@filter.valid_filter_params)
  end
end
