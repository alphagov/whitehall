module Admin
  class StatisticsAnnouncementFilter

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def statistics_announcements
      scope = unfiltered_scope
      scope = scope.with_title_containing(options[:title]) if options[:title]
      scope = scope.joins(:organisations).where('statistics_announcement_organisations.organisation_id' => options[:organisation_id]) if options[:organisation_id].present?
      scope
    end

    private

    def unfiltered_scope
      StatisticsAnnouncement.includes(:current_release_date)
                            .order(current_release_date: :release_date)
                            .page(options[:page])
    end
  end
end
