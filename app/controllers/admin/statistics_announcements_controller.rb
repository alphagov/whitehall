class Admin::StatisticsAnnouncementsController < Admin::BaseController
  before_filter :restrict_access_to_gds_editors_and_ons_users
  before_filter :find_statistics_announcement, only: [:show, :edit, :update, :destroy]

  def index
    @statistics_announcements = StatisticsAnnouncement.
                                  includes(:current_release_date).
                                  order(current_release_date: :release_date ).
                                  page(params[:page])
  end

  def new
    @statistics_announcement = build_statistics_announcement(organisation_id: current_user.organisation.try(:id))
    @statistics_announcement.build_current_release_date(precision: StatisticsAnnouncementDate::PRECISION[:two_month])
  end

  def create
    @statistics_announcement = build_statistics_announcement(statistics_announcement_params)

    if @statistics_announcement.save
      redirect_to [:admin, @statistics_announcement], notice: "Announcement saved successfully"
    else
      render :new
    end
  end

  def edit
  end

  def update
    @statistics_announcement.attributes = statistics_announcement_params
    if @statistics_announcement.save
      redirect_to [:admin, @statistics_announcement], notice: "Announcement updated successfully"
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
    attributes[:current_release_date_attributes] &&
      attributes[:current_release_date_attributes][:creator_id] = current_user.id

    current_user.statistics_announcements.new(attributes)
  end

  def statistics_announcement_params
    params.require(:statistics_announcement).permit(
      :title, :summary, :organisation_id, :topic_id, :publication_type_id, :publication_id,
      current_release_date_attributes: [:id, :release_date, :precision, :confirmed])
  end
end
