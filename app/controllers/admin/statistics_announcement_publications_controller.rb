class Admin::StatisticsAnnouncementPublicationsController < Admin::BaseController
  before_action :find_statistics_announcement
  layout "design_system"

  def index; end

  private
  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.friendly.find(params[:statistics_announcement_id])
  end
end
