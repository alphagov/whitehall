class Admin::StatisticsAnnouncementPublicationsController < Admin::BaseController
  before_action :find_statistics_announcement
  layout "design_system"

  def index
    get_editions
  end

  def connect
    @statistics_announcement.assign_attributes(publication_params)

    if @statistics_announcement.save
      redirect_to [:admin, @statistics_announcement], notice: "Announcement updated successfully"
    else
      get_editions
      render :index
    end
  end

private

  def get_editions
    if params[:search].present?
      @editions = Edition.statistical_publications.with_title_containing(params[:search])
    end
  end

  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.friendly.find(params[:statistics_announcement_id])
  end

  def publication_params
    { publication_id: params[:publication_id] }
  end
end
