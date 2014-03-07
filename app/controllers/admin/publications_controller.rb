class Admin::PublicationsController < Admin::EditionsController
  include Admin::EditionsController::NationalApplicability

  before_filter :build_image, only: [:new, :edit]
  before_filter :pre_fill_edition_from_release_announcement, only: :new, if: :release_announcement

  private

  def edition_class
    Publication
  end

  def permitted_edition_attributes
    super << :statistical_release_announcement_id
  end

  def pre_fill_edition_from_release_announcement
    @edition.statistical_release_announcement_id = release_announcement.id
    @edition.title = release_announcement.title
    @edition.summary = release_announcement.summary
    @edition.publication_type = release_announcement.publication_type
    @edition.topics = [release_announcement.topic]
    @edition.scheduled_publication = release_announcement.expected_release_date
  end

  def release_announcement
    if params[:statistical_release_announcement_id]
      @release_announcement ||= StatisticalReleaseAnnouncement.find(params[:statistical_release_announcement_id])
    end
  end
end
