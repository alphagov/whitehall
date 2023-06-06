class Admin::StatisticsAnnouncementUnpublishingsController < Admin::BaseController
  before_action :find_statistics_announcement
  before_action :enforce_permissions!
  layout :get_layout

  def new
    render_design_system("new", "legacy_new")
  end

  def create
    if @statistics_announcement.update(statistics_announcement_params.merge(publishing_state: "unpublished"))
      redirect_to admin_statistics_announcements_path, notice: "Unpublished statistics announcement: #{@statistics_announcement.title}"
    else
      render_design_system("new", "legacy_new")
    end
  end

private

  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.friendly.find(params[:statistics_announcement_id])
  end

  def statistics_announcement_params
    params.require(:statistics_announcement).permit(:redirect_url)
  end

  def enforce_permissions!
    enforce_permission!(:unpublish, @statistics_announcement)
  end

  def get_layout
    if preview_design_system?(next_release: false)
      "design_system"
    else
      "admin"
    end
  end
end
