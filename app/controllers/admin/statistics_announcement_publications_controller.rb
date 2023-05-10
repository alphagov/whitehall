class Admin::StatisticsAnnouncementPublicationsController < Admin::BaseController
  before_action :find_statistics_announcement
  layout "design_system"

  def index
    if params[:search].present?
      @editions = Edition.statistical_publications.with_title_containing(params[:search])
    end
  end

  def connect
    @statistics_announcement.assign_attributes(publication_params)

    @statistics_announcement.save

    redirect_to [:admin, @statistics_announcement], notice: "Announcement updated successfully"
  end

private

  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.friendly.find(params[:statistics_announcement_id])
  end

  def publication_params
    { publication_id: params[:publication_id] }
  end
end
