class Admin::StatisticsAnnouncementDatesController < Admin::BaseController
  before_filter :find_statistics_announcement

  def new
    current_attributes = @statistics_announcement.current_release_date.attributes.slice(*permitted_attributes.map(&:to_s))
    @statistics_announcement_date = @statistics_announcement.statistics_announcement_dates.build(current_attributes)
  end

  def create
    @statistics_announcement_date = @statistics_announcement.statistics_announcement_dates.build(statistics_announcement_date_params)
    if @statistics_announcement_date.save
      redirect_to [:admin, @statistics_announcement], notice: 'Release date changed'
    else
      render :new
    end
  end

private

  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.find(params[:statistics_announcement_id])
  end

  def permitted_attributes
    [:release_date, :confirmed, :precision, :change_note]
  end

  def statistics_announcement_date_params
    params.require(:statistics_announcement_date).permit(*permitted_attributes)
  end
end
