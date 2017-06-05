class Admin::StatisticsAnnouncementsController < Admin::BaseController
  before_action :find_statistics_announcement, only: [:show, :edit, :update, :cancel, :publish_cancellation, :cancel_reason]
  before_action :redirect_to_show_if_cancelled, only: [:cancel, :publish_cancellation]
  helper_method :unlinked_announcements_count, :show_unlinked_announcements_warning?

  def index
    @filter = Admin::StatisticsAnnouncementFilter.new(filter_params)
    @statistics_announcements = @filter.statistics_announcements
  end

  def show
    if @statistics_announcement.can_be_tagged_to_taxonomy?
      @expanded_links = ExpandedLinksFetcher.new(@statistics_announcement.content_id).fetch
    end
  end

  def new
    @statistics_announcement = build_statistics_announcement(organisation_ids: [current_user.organisation.try(:id)])
    @statistics_announcement.build_current_release_date(precision: StatisticsAnnouncementDate::PRECISION[:two_month])
  end

  def create
    @statistics_announcement = build_statistics_announcement(statistics_announcement_params)

    if @statistics_announcement.save
      redirect_to [:admin, @statistics_announcement], notice: "Announcement published successfully"
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

  def cancel
  end

  def publish_cancellation
    if @statistics_announcement.cancel!(params[:statistics_announcement][:cancellation_reason], current_user)
      redirect_to [:admin, @statistics_announcement], notice: "Announcement has been cancelled"
    else
      render :cancel
    end
  end

private

  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.friendly.find(params[:id])
  end

  def redirect_to_show_if_cancelled
    redirect_to [:admin, @statistics_announcement] if @statistics_announcement.cancelled?
  end

  def build_statistics_announcement(attributes = {})
    if attributes[:current_release_date_attributes]
      attributes[:current_release_date_attributes][:creator_id] = current_user.id
    end

    current_user.statistics_announcements.new(attributes)
  end

  def statistics_announcement_params
    params.require(:statistics_announcement).permit(
      :title, :summary, :publication_type_id, :publication_id,
      :cancellation_reason, organisation_ids: [], topic_ids: [],
      current_release_date_attributes: [:id, :release_date, :precision, :confirmed])
  end

  def filter_params
    params.slice(:title, :page, :per_page, :organisation_id, :dates, :unlinked_only).
      reverse_merge(filter_defaults)
  end

  def filter_defaults
    {
      organisation_id: current_user.organisation.try(:id),
      dates: 'future',
      user_id: current_user.id
    }
  end

  def show_unlinked_announcements_warning?
    !filtering_imminent_unlinked_announcements? && unlinked_announcements_count > 0
  end

  def filtering_imminent_unlinked_announcements?
    @filter.options[:dates] == 'imminent' && @filter.options[:unlinked_only] == '1'
  end

  def unlinked_announcements_count
    unlinked_announcements_filter.statistics_announcements.total_count
  end

  def unlinked_announcements_filter
    @unlinked_announcements_filter ||= Admin::StatisticsAnnouncementFilter.new(dates: 'imminent', unlinked_only: '1', organisation_id: filter_params[:organisation_id])
  end
end
