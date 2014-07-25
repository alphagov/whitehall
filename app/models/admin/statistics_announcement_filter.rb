module Admin
  class StatisticsAnnouncementFilter

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def statistics_announcements
      results = unfiltered_results
      results = results.with_title_containing(options[:title]) if options[:title]

      results
    end

    private

    def unfiltered_results
      StatisticsAnnouncement.includes(:current_release_date)
                            .order(current_release_date: :release_date)
                            .page(options[:page])
    end
  end
end
