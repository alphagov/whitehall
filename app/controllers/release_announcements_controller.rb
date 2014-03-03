class ReleaseAnnouncementsController < PublicFacingController
  def index
    @release_announcements = Frontend::ReleaseAnnouncementProvider.all
  end
end
