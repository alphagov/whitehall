module Admin
  class StatisticsAnnouncementFilter

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def statistics_announcements
      scope = unfiltered_scope
      scope = scope.with_title_containing(options[:title]) if options[:title].present?
      scope = scope.in_organisations([options[:organisation_id]]) if options[:organisation_id].present?
      scope = scope.merge( date_and_order_scope )
      scope
    end

    private

    def unfiltered_scope
      StatisticsAnnouncement.includes(:current_release_date)
                            .joins(:current_release_date)
                            .page(options[:page])
    end

    def date_and_order_scope
      case options[:dates]
      when 'past'
        StatisticsAnnouncement.where("release_date < ?", Time.zone.now)
                              .order("release_date DESC")
      when 'future'
        StatisticsAnnouncement.where("release_date > ?", Time.zone.now)
                              .order("release_date ASC")
      else
        StatisticsAnnouncement.order("release_date DESC")
      end
    end
  end
end
