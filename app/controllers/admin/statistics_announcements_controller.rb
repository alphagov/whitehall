class Admin::StatisticsAnnouncementsController < Admin::BaseController
  before_filter :find_statistics_announcement, only: [:edit, :update, :destroy]

  def new
    @statistics_announcement = build_statistics_announcement(organisation_id: current_user.organisation.try(:id))
  end

  def create
    @statistics_announcement = build_statistics_announcement(statistics_announcement_params)

    if @statistics_announcement.save
      redirect_to admin_root_url, notice: "Announcement saved successfully"
    else
      render :new
    end
  end

  def edit
  end

  def update
    @statistics_announcement.attributes = statistics_announcement_params
    path_to_redirect = @statistics_announcement.publication_id_changed? ? [:edit, :admin, @statistics_announcement] : admin_root_url
    if @statistics_announcement.save
      redirect_to path_to_redirect, notice: "Announcement updated successfully"
    else
      render :edit
    end
  end

  def destroy
    if @statistics_announcement.destroy
      redirect_to admin_root_url, notice: "Announcement deleted successfully"
    else
      redirect_to admin_root_url, alert: "There was a problem deleting the announcement"
    end
  end

  private

  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.find(params[:id])
  end

  def build_statistics_announcement(attributes={})
    current_user.statistics_announcements.new(attributes)
  end

  def statistics_announcement_params
    params.require(:statistics_announcement).permit(
      :title, :summary, :expected_release_date, :display_release_date_override,
      :organisation_id, :topic_id, :publication_type_id, :publication_id)
  end
end
