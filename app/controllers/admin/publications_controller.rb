class Admin::PublicationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  before_filter :build_image, only: [:new, :edit]
  before_filter :pre_fill_edition_from_statistics_announcement, only: :new, if: :statistics_announcement

  private

  def edition_class
    Publication
  end

  def permitted_edition_attributes
    super << :statistics_announcement_id
  end

  def pre_fill_edition_from_statistics_announcement
    @edition.statistics_announcement_id = statistics_announcement.id
    @edition.title = statistics_announcement.title
    @edition.summary = statistics_announcement.summary
    @edition.publication_type = statistics_announcement.publication_type
    @edition.topics = [statistics_announcement.topic]
    @edition.scheduled_publication = statistics_announcement.release_date
  end

  def statistics_announcement
    if params[:statistics_announcement_id]
      @statistics_announcement ||= StatisticsAnnouncement.find(params[:statistics_announcement_id])
    end
  end
end
