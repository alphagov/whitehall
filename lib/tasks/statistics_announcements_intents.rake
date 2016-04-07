namespace :statistics_announcements do
  def no_update_required?(statistics_announcement)
    statistics_announcement.unpublished? || statistics_announcement.cancelled?
  end

  desc "Updates the publish intent for StatisticsAnnouncements scheduled for release in the future"
  task put_intents_for_scheduled: :environment do
    latest_join_sql = <<-SQL
      statistics_announcement_dates.created_at = (
        select max(statistics_announcement_dates.created_at)
        from statistics_announcement_dates
        where statistics_announcement_dates.statistics_announcement_id = statistics_announcements.id
      )
    SQL

    statistics_announcements = StatisticsAnnouncement
      .joins(:statistics_announcement_dates)
      .where("statistics_announcement_dates.release_date > ?", Date.current)
      .where(latest_join_sql)

    statistics_announcements.each do |statistics_announcement|
      unless no_update_required?(statistics_announcement)
        statistics_announcement.update_publish_intent
      end
    end
  end
end
