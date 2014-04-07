class Admin::StatisticsAnnouncementDateChangesController < Admin::BaseController
  before_filter :restrict_access_to_gds_editors_and_ons_users
  before_filter :find_statistics_announcement

  def new
    @statistics_announcement_date_change = build_date_change
  end

  def create
    @statistics_announcement_date_change = build_date_change(date_change_params)

    if @statistics_announcement_date_change.save
      redirect_to [:admin, @statistics_announcement], notice: 'Release date changed'
    else
      render :new
    end
  end

private

  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.find(params[:statistics_announcement_id])
  end

  def build_date_change(attributes={})
    attributes[:creator_id] = current_user.id
    @statistics_announcement.build_statistics_announcement_date_change(attributes)
  end

  def date_change_params
    params.require(:statistics_announcement_date_change).
           permit(:release_date, :confirmed, :precision, :change_note)
  end
end
