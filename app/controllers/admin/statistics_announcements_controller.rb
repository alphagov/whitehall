class Admin::StatisticsAnnouncementsController < Admin::BaseController
  before_filter :find_statistics_announcement, only: [:show, :edit, :update, :destroy]

  def index
    @filter = Admin::StatisticsAnnouncementFilter.new(filter_params)
    @statistics_announcements = @filter.statistics_announcements
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
    @statistics_announcement.destroy
    redirect_to [:admin, :statistics_announcements], notice: "Announcement deleted successfully"
  end

  private

  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.find(params[:id])
  end

  def build_statistics_announcement(attributes = {})
    if attributes[:current_release_date_attributes]
      attributes[:current_release_date_attributes][:creator_id] = current_user.id
    end

    current_user.statistics_announcements.new(attributes)
  end

  def statistics_announcement_params
    params.require(:statistics_announcement).permit(
      :title, :summary, :organisation_id, :topic_id, :publication_type_id, :publication_id,
      current_release_date_attributes: [:id, :release_date, :precision, :confirmed])
  end

  def filter_params
    params.slice(:title, :page, :per_page)
  end
end
