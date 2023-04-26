class Admin::StatisticsAnnouncementsController < Admin::BaseController
  before_action :set_release_date_params, only: %i[create]
  before_action :find_statistics_announcement, only: %i[show edit update cancel publish_cancellation cancel_reason]
  before_action :redirect_to_show_if_cancelled, only: %i[cancel publish_cancellation]
  helper_method :unlinked_announcements_count, :show_unlinked_announcements_warning?
  layout :get_layout

  def cancel_reason; end

  def index
    @filter = Admin::StatisticsAnnouncementFilter.new(filter_params)
    @statistics_announcements = @filter.statistics_announcements
  end

  def show
    @edition_taxons = EditionTaxonsFetcher.new(@statistics_announcement.content_id).fetch
  end

  def new
    @statistics_announcement = build_statistics_announcement(organisation_ids: [current_user.organisation.try(:id)])
    @statistics_announcement.build_current_release_date(precision: StatisticsAnnouncementDate::PRECISION[:two_month])

    render_design_system("new", "legacy_new", next_release: false)
  end

  def create
    @statistics_announcement = build_statistics_announcement(statistics_announcement_params)

    if @statistics_announcement.save
      redirect_to [:admin, @statistics_announcement], notice: "Announcement published successfully"
    else
      render_design_system("new", "legacy_new", next_release: false)
    end
  end

  def edit
    render_design_system("edit", "legacy_edit", next_release: false)
  end

  def update
    @statistics_announcement.attributes = statistics_announcement_params
    if @statistics_announcement.save
      redirect_to [:admin, @statistics_announcement], notice: "Announcement updated successfully"
    else
      render_design_system("edit", "legacy_edit", next_release: false)
    end
  end

  def cancel
    render_design_system("cancel", "legacy_cancel", next_release: false)
  end

  def publish_cancellation
    if @statistics_announcement.cancel!(params[:statistics_announcement][:cancellation_reason], current_user)
      redirect_to [:admin, @statistics_announcement], notice: "Announcement has been cancelled"
    else
      render_design_system("cancel", "legacy_cancel", next_release: false)
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

  def set_release_date_params(attributes = params[:statistics_announcement][:current_release_date_attributes])
    return if attributes.blank?

    if attributes[:precision] == "exact_confirmed"
      attributes[:precision] = StatisticsAnnouncementDate::PRECISION[:exact]
      attributes[:confirmed] = true
    else
      attributes[:confirmed] = false
    end
  end

  def statistics_announcement_params
    params
      .require(:statistics_announcement)
      .permit(
        :title,
        :summary,
        :publication_type_id,
        :publication_id,
        :cancellation_reason,
        organisation_ids: [],
        topic_ids: [],
        current_release_date_attributes: %i[id release_date precision confirmed],
      )
  end

  def filter_params
    params.slice(:title, :page, :per_page, :organisation_id, :dates, :unlinked_only)
          .permit!
          .to_h
          .reverse_merge(filter_defaults)
  end

  def filter_defaults
    {
      organisation_id: current_user.organisation.try(:id),
      dates: "future",
      user_id: current_user.id,
    }
  end

  def show_unlinked_announcements_warning?
    !filtering_imminent_unlinked_announcements? && unlinked_announcements_count.positive?
  end

  def filtering_imminent_unlinked_announcements?
    @filter.options[:dates] == "imminent" && @filter.options[:unlinked_only] == "1"
  end

  def unlinked_announcements_count
    unlinked_announcements_filter.statistics_announcements.total_count
  end

  def unlinked_announcements_filter
    @unlinked_announcements_filter ||= Admin::StatisticsAnnouncementFilter.new(dates: "imminent", unlinked_only: "1", organisation_id: filter_params[:organisation_id])
  end

  def get_layout
    design_system_actions = []
    design_system_actions += %w[edit update new create cancel publish_cancellation] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end
end
