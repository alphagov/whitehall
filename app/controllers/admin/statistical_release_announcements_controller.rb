class Admin::StatisticalReleaseAnnouncementsController < Admin::BaseController
  before_filter :find_release_announcement, only: [:edit, :update, :destroy]

  def new
    @release_announcement = build_announcement(organisation_id: current_user.organisation.try(:id))
  end

  def create
    @release_announcement = build_announcement(statistical_release_announcement_params)

    if @release_announcement.save
      redirect_to admin_root_url, notice: "Announcement saved successfully"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @release_announcement.update_attributes(statistical_release_announcement_params)
      redirect_to admin_root_url, notice: "Announcement updated successfully"
    else
      render :edit
    end
  end

  def destroy
    if @release_announcement.destroy
      redirect_to admin_root_url, notice: "Announcement deleted successfully"
    else
      redirect_to admin_root_url, alert: "There was a problem deleting the announcement"
    end
  end

  private

  def find_release_announcement
    @release_announcement = StatisticalReleaseAnnouncement.find(params[:id])
  end

  def build_announcement(attributes={})
    current_user.statistical_release_announcements.new(attributes)
  end

  def statistical_release_announcement_params
    params.require(:statistical_release_announcement).permit(
      :title, :summary, :expected_release_date, :display_release_date_override,
      :organisation_id, :topic_id, :publication_type_id
    )
  end
end
