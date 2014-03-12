class Admin::StatisticalReleaseAnnouncementsController < Admin::BaseController
  before_filter :find_release_announcement, only: [:edit, :update, :destroy]

  def new
    @release_announcement = build_release_announcement(organisation_id: current_user.organisation.try(:id))
  end

  def create
    @release_announcement = build_release_announcement(release_announcement_params)

    if @release_announcement.save
      redirect_to admin_root_url, notice: "Announcement saved successfully"
    else
      render :new
    end
  end

  def edit
  end

  def update
    @release_announcement.attributes = release_announcement_params
    path_to_redirect = @release_announcement.publication_id_changed? ? [:edit, :admin, @release_announcement] : admin_root_url
    if @release_announcement.save
      redirect_to path_to_redirect, notice: "Announcement updated successfully"
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

  def build_release_announcement(attributes={})
    current_user.statistical_release_announcements.new(attributes)
  end

  def release_announcement_params
    params.require(:statistical_release_announcement).permit(
      :title, :summary, :expected_release_date, :display_release_date_override,
      :organisation_id, :topic_id, :publication_type_id, :publication_id
    )
  end
end
